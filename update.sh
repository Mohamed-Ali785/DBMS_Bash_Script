#!/usr/bin/bash
clear

DB_path=$1

while true
do
read -p "Enter Table Name: " tb
if [[ -z "$tb" || "$tb" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid Table Name"
    continue
fi
data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

if [[ ! -f $data || ! -f $meta ]]; then
    echo "Table does not exist"
    continue
fi
break
done


while true
do
read -p "Enter column to update: " upd_col
if [[ -z "$upd_col" || "$upd_col" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid Column Name"
    continue
fi
read t ispk <<< $(awk -F: -v col="$upd_col" '
{ 
if(col==$1){
                if ($3 == "PK") pk = 1
                print $2 ,(pk?1:0)
                exit
            }
}' "$meta")
if [[ -z "$t" ]];then
    echo "Invalid Column Name"
    continue
fi
if [[ $ispk -eq 1 ]]; then
    echo "Error: Cannot update Primary Key column"
    continue
fi
break
done


while true
do
read -p "Enter new value: " new_val
if [[ -n $new_val && $t == "int" && ! "$new_val" =~ ^[0-9]+$  ]]; then
            echo "Error: Invalid Integer"
            continue
fi
break
done

while true
do
read -p "Enter WHERE column: " where_col
if [[ -z "$where_col" || "$where_col" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid Column Name"
    continue
fi
type=$(awk -F: -v coll="$where_col" '
{ if(coll==$1)  {print $2; exit;}}' "$meta")
if [[ -z "$type" ]]; then
    echo "Invalid Column Name"
    continue
fi
break
done

while true
do
read -p "Enter WHERE value: " where_val
if [[ -n $where_val && $type == "int" && ! "$where_val" =~ ^[0-9]+$  ]]; then
            echo "Error: Invalid Integer"
            continue
fi
break
done
read upcolnum wherecolnum <<< $(
awk -F: -v up="$upd_col" -v wh="$where_col" '
{
    if ($1 == up) u = NR
    if ($1 == wh) w = NR     
}
END {print u, w}' "$meta")


if [[ "$type" != "string" ]]; then
        read -p "Choose operator (=, !=, >, <, >=, <=): " op
else
        read -p "Choose operator (=, !=): " op
fi
awk -F'|' -v OFS='|' -v uc="$upcolnum" -v wc="$wherecolnum" -v uv="$new_val" -v wv="$where_val" -v op="$op" '
{
    if ((op=="="  && $wc==wv)   ||
        (op=="!=" && $wc!=wv)   ||
        (op==">"  && $wc>wv)    ||
        (op=="<"  && $wc<wv)    ||
        (op==">=" && $wc>=wv)   ||
        (op=="<=" && $wc<=wv)   )
        $uc = uv
    print $0
}' "$data" > "$data.tmp" && mv "$data.tmp" "$data"
while true
do
read -p "Table Menu?(Y/N): " c
if [[ $c =~ ^[Yy]([Ee][Ss])?$ ]]; then
    clear
    break
else
    continue
fi
done
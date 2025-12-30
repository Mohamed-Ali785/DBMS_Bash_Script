#!/usr/bin/bash
DB_path=$1

read -p "Enter Table Name: " tb
if [[ -z "$tb" || "$tb" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid Table Name"
    exit 1
fi
data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

if [[ ! -f $data || ! -f $meta ]]; then
    echo "Table does not exist"
    exit 1
fi

read -p "Enter column to update: " upd_col
read -p "Enter new value: " new_val

read -p "Enter WHERE column: " where_col
read -p "Enter WHERE value: " where_val

read upcolnum wherecolnum ispk type<<< $(
awk -F: -v up="$upd_col" -v wh="$where_col" '
{
    if ($1 == up) {
        u = NR
        if ($3 == "PK") pk = 1
    }
    if ($1 == wh) {
        w = NR
        t=$2
    }
        
}
END {
    print (u?u:0), (w?w:0), (pk?1:0) ,(t?t:"")
}' "$meta")

if [[ $upcolnum -eq 0 || $wherecolnum -eq 0 ]]; then
    echo "Invalid column name"
    exit 1
fi
if [[ $ispk -eq 1 ]]; then
    echo "Error: Cannot update Primary Key column"
    exit 1
fi
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

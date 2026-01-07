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

echo "1) Delete table"
echo "2) Delete with condition"
read -p "choose: " ch

case $ch in
    1)  
        sed -i '1,$d' "$data"
        ;;

    2)  while true
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

        colnum=$(awk -F: -v col="$where_col" '
        {
            if($1==col){
                print NR
                exit
            }
        }' "$meta")

        if [[ "$type" != "string" ]]; then
            read -p "Choose operator (=, !=, >, <, >=, <=): " op
        else
            read -p "Choose operator (=, !=): " op
        fi

        typeset -a rownum
        i=0
        while read -r line; do
            rownum[i]="$line"
            ((i++))
        done < <(awk -F'|' -v c="$colnum" -v v="$where_val" -v op="$op" '
        {
            if( (op=="=" && $c==v)   ||
                (op=="!=" && $c!=v)  ||
                (op==">" && $c>v)    ||
                (op=="<" && $c<v)    ||
                (op==">=" && $c>=v)  ||
                (op=="<=" && $c<=v)  )
                print NR 
        }' "$data")
        
        if [[ ${#rownum[@]} -eq 0 ]]; then
            echo "No matching row found"
            exit 1
        fi

        for (( j=${#rownum[@]}-1; j>=0; j-- )); do
            sed -i "${rownum[j]}d" "$data"
        done
        ;;

    *)  
        echo "Invalid choice"
        ;;
esac

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
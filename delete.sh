#!/usr/bin/bash

read -p "Enter Database Name: " db
read -p "Enter Table Name: " tb

data="Databases/$db/$tb.data"
meta="Databases/$db/$tb.meta"

if [[ ! -f $meta || ! -f $data ]]; then
    echo "Table does not exist"
    exit 1
fi

echo "1) Delete table"
echo "2) Delete with condition"
read -p "choose: " ch

case $ch in
    1)  
        sed -i '1,$d' "$data"
        ;;

    2)  read -p "Enter Column Name: " col
        read -p "Enter Value: " value

        read t colnum <<< $(awk -F: -v col="$col" '
        {
            if($1==col){
                print $2, NR
                exit
            }
        }' "$meta")

        if [[ -z $colnum ]]; then
            echo "Column not found"
            exit 1
        fi

        if [[ "$t" != "string" ]]; then
            read -p "Choose operator (=, !=, >, <, >=, <=): " op
        else
            read -p "Choose operator (=, !=): " op
        fi

        typeset -a rownum
        i=0

        while read -r line; do
            rownum[i]="$line"
            ((i++))
        done < <(awk -F'|' -v c="$colnum" -v v="$value" -v op="$op" '
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

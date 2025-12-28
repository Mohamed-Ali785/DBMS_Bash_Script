#!/usr/bin/bash

read -p "Enter Database Name: " db
read -p "Enter Table Name: " tb

data="Databases/$db/$tb.data"
meta="Databases/$db/$tb.meta"

if [[ ! -f $data || ! -f $meta ]]; then
    echo "Table does not exist"
    exit 1
fi

i=0
while read -r line pk type; do
    col_name[i]="$line"
    is_pk[i]="$pk"
    types[i]="$type" 
    ((i++))
done < <(awk -F: '{pk=($3=="PK"?1:0); print $1 ,pk ,$2}' "$meta")

count=$i
row=""

for ((i=0; i<count; i++))
do
    while true
    do
        read -p "Enter value for ${col_name[i]}: " val

        if [[ -n $val && ${types[i]} == "int" && ! "$val" =~ ^[0-9]+$  ]]; then
            echo "Error: Invalid Integer"
            continue
        fi

        if [[ ${is_pk[i]} -eq 1 ]]; then
            pk_in=$((i+1))
            flag=$(awk -F'|' -v val="$val" -v indx="$pk_in" '
            {
                if ($indx == val) {
                    print 1
                    exit 1
                }
            }' "$data")
            if [[ -n $val && -z $flag ]]; then
                break
            else
                echo "Error: Value '$val' for ${col_name[i]} already exists (PK must be Unique and Not Empty).Try again."
                continue
            fi
        else
            break
        fi
    done

    if [[ -z $row ]]; then
        row="$val"
    else
        row="$row|$val"
    fi
done

echo "$row" >> "$data"

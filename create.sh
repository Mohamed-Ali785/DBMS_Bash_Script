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

    if [[ -f $data && -f $meta ]]; then
        echo "Table exists, Try Again"
        continue
    fi

    tm=$(mktemp)

while true
do
    read -p "Enter Column Name: " name

    if [[ -z "$name" || "$name" =~ [^a-zA-Z0-9_] ]]; then
        echo "Invalid Column Name"
        continue
    fi

    if [[ -s "$tm" ]]; then
        if awk -F: -v col="$name" '$1==col {found=1} END{exit !found}' "$tm"
        then
            echo "Column exists, try again"
            continue
        fi
    fi

    read -p "Enter Column type (int/string): " t
    if [[ $t != "int" && $t != "string" ]]; then
        echo "Invalid type"
        continue
    fi

    while true
    do
        read -p "Is this Primary Key? (y/n): " p
        case "$p" in
            y|Y)
                echo "$name:$t:PK" >> "$tm"
                break
                ;;
            n|N)
                echo "$name:$t" >> "$tm"
                break
                ;;
            *)
                echo "Enter y or n"
                ;;
        esac
    done

    read -p "Add another column? (y/n): " c
    [[ $c =~ ^[Yy]$ ]] || break
done

touch "$data"
mv "$tm" "$meta"
echo "Table '$tb' created successfully."


read -p "Table Menu?(Y/N): " c
if [[ $c =~ ^[Yy]([Ee][Ss])?$ ]]; then
    clear
    break
else
    clear
    continue
fi
done
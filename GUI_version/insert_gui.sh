#!/bin/bash

DB_path=$1
tb=$(zenity --entry --title="Insert Data" --text="Enter Table Name:")

if [[ -z "$tb" ]]; then exit 0; fi

meta="$DB_path/$tb.meta"
data="$DB_path/$tb.data"

if [[ ! -f "$meta" ]]; then
    zenity --error --text="Table '$tb' does not exist."
    exit 1
fi

row=""
# Read meta line by line
while IFS= read -r line; do
    # Parse Meta: Name:Type:PK
    col_name=$(echo "$line" | cut -d: -f1)
    col_type=$(echo "$line" | cut -d: -f2)
    is_pk=$(echo "$line" | cut -d: -f3)

    while true; do
        val=$(zenity --entry --title="Insert into $tb" --text="Enter value for '$col_name' ($col_type) ${is_pk:+[PK]}:")
        
        if [[ -z "$val" && "$is_pk" == "PK" ]]; then
            zenity --error --text="Primary Key cannot be empty."
            continue
        fi
        
        # Cancel check
        if [[ $? -ne 0 ]]; then exit 1; fi

        # Int Validation
        if [[ "$col_type" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
            zenity --error --text="Value must be an Integer."
            continue
        fi

        # PK Uniqueness Check
        if [[ "$is_pk" == "PK" ]]; then
            # Find column index
            col_idx=$(awk -F: -v c="$col_name" '{if($1==c) print NR}' "$meta")
            # Check data file
            if grep -q "^$val$" <(cut -d'|' -f"$col_idx" "$data"); then
                zenity --error --text="Duplicate Primary Key '$val' found."
                continue
            fi
        fi
        break
    done

    if [[ -z "$row" ]]; then row="$val"; else row="$row|$val"; fi

done < "$meta"

echo "$row" >> "$data"
zenity --info --text="Row inserted successfully."
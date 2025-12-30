#!/bin/bash

DB_path=$1

# 1. Get Table Name
while true; do
    tb=$(zenity --entry --title="Create Table" --text="Enter Table Name:")
    
    # Handle Cancel
    if [[ -z "$tb" ]]; then exit 0; fi

    if [[ "$tb" =~ [^a-zA-Z0-9_] ]]; then
        zenity --error --text="Invalid Table Name. Alphanumeric only."
        continue
    fi

    if [[ -f "$DB_path/$tb.meta" ]]; then
        zenity --error --text="Table '$tb' already exists."
        continue
    fi
    break
done

tm=$(mktemp)
touch "$tm"

# 2. Add Columns Loop
while true; do
    # Form to get column details
    form_out=$(zenity --forms --title="Add Column to '$tb'" \
        --text="Enter Column Details" \
        --add-entry="Column Name" \
        --add-combo="Type" --combo-values="int|string" \
        --add-combo="Primary Key?" --combo-values="no|yes")

    if [[ -z "$form_out" ]]; then
        # If user cancels mid-creation, cleanup and exit
        rm "$tm"
        zenity --info --text="Table creation cancelled."
        exit 0
    fi

    name=$(echo "$form_out" | cut -d'|' -f1)
    type=$(echo "$form_out" | cut -d'|' -f2)
    pk_ans=$(echo "$form_out" | cut -d'|' -f3)

    # Validation
    if [[ -z "$name" || "$name" =~ [^a-zA-Z0-9_] ]]; then
        zenity --error --text="Invalid Column Name."
        continue
    fi

    # Check Duplicate in temp file
    if grep -q "^$name:" "$tm"; then
        zenity --error --text="Column '$name' already exists in this table."
        continue
    fi

    # Logic for PK string
    pk_str=""
    if [[ "$pk_ans" == "yes" ]]; then
        # Check if PK already defined (optional logic, script allows composite PK? 
        # Original script didn't explicitly block multiple PKs, but usually only one is allowed. 
        # We will follow original script logic which allows marking it)
        pk_str=":PK"
    fi

    echo "$name:$type$pk_str" >> "$tm"

    # Ask to continue
    zenity --question --text="Column '$name' added. Add another column?"
    if [[ $? -ne 0 ]]; then
        break
    fi
done

# Finalize
if [[ -s "$tm" ]]; then
    touch "$DB_path/$tb.data"
    mv "$tm" "$DB_path/$tb.meta"
    zenity --info --text="Table '$tb' created successfully!"
else
    rm "$tm"
    zenity --warning --text="No columns defined. Table not created."
fi
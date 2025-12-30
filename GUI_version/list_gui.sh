#!/bin/bash

DB_path=$1
tables=$(ls "$DB_path"/*.meta 2>/dev/null)

if [[ -z "$tables" ]]; then
    zenity --info --text="No tables found in database."
else
    # Prepare list for zenity
    list_content=""
    for t in $tables; do
        t_name=$(basename "$t" .meta)
        list_content="$list_content $t_name"
    done
    
    # Display in a simple list
    echo "$list_content" | tr ' ' '\n' | zenity --list --title="Tables List" --column="Table Name" --height=300
fi
#!/bin/bash

DB_path=$1
tb=$(zenity --entry --title="Delete Data" --text="Enter Table Name:")

if [[ -z "$tb" ]]; then exit 0; fi

data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

if [[ ! -f "$meta" ]]; then
    zenity --error --text="Table not found."
    exit 1
fi

action=$(zenity --list --title="Delete Options" --column="Action" "Delete All Rows" "Delete with Condition")

if [[ "$action" == "Delete All Rows" ]]; then
    sed -i '1,$d' "$data"
    zenity --info --text="All rows deleted from '$tb'."
elif [[ "$action" == "Delete with Condition" ]]; then
    
    # Get Condition
    form_out=$(zenity --forms --title="Delete Condition" \
        --text="Where..." \
        --add-entry="Column Name" \
        --add-entry="Value" \
        --add-combo="Operator" --combo-values="=|!=|>|<|>=|<=")
    
    col=$(echo "$form_out" | cut -d'|' -f1)
    val=$(echo "$form_out" | cut -d'|' -f2)
    op=$(echo "$form_out" | cut -d'|' -f3)

    if [[ -z "$col" || -z "$op" ]]; then exit 1; fi

    # Find Column Index
    col_idx=$(awk -F: -v c="$col" '{if($1==c) print NR}' "$meta")
    
    if [[ -z "$col_idx" ]]; then
        zenity --error --text="Column '$col' not found."
        exit 1
    fi

    # Perform Delete using awk to find lines, then sed to delete
    # (Using a temporary file approach is safer/easier for complex logic than in-place sed with line numbers)
    awk -F'|' -v c="$col_idx" -v v="$val" -v op="$op" '
    BEGIN { OFS="|" }
    {
        keep = 1
        if (op == "=" && $c == v) keep=0
        else if (op == "!=" && $c != v) keep=0
        else if (op == ">" && $c > v) keep=0
        else if (op == "<" && $c < v) keep=0
        else if (op == ">=" && $c >= v) keep=0
        else if (op == "<=" && $c <= v) keep=0
        
        if (keep == 1) print $0
    }' "$data" > "$data.tmp" && mv "$data.tmp" "$data"

    zenity --info --text="Delete operation completed."
fi
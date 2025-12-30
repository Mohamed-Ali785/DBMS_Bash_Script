#!/bin/bash

DB_path=$1
tb=$(zenity --entry --title="Update Table" --text="Enter Table Name:")

if [[ -z "$tb" ]]; then exit 0; fi

data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

if [[ ! -f "$meta" ]]; then
    zenity --error --text="Table not found."
    exit 1
fi

# Form for Update Logic
form_out=$(zenity --forms --title="Update Row" \
    --text="SET Column = Value WHERE Column = Value" \
    --add-entry="SET Column Name" \
    --add-entry="New Value" \
    --add-entry="WHERE Column Name" \
    --add-entry="WHERE Value" \
    --add-combo="Operator (for WHERE)" --combo-values="=|!=|>|<|>=|<=")

if [[ -z "$form_out" ]]; then exit 0; fi

set_col=$(echo "$form_out" | cut -d'|' -f1)
new_val=$(echo "$form_out" | cut -d'|' -f2)
where_col=$(echo "$form_out" | cut -d'|' -f3)
where_val=$(echo "$form_out" | cut -d'|' -f4)
op=$(echo "$form_out" | cut -d'|' -f5)

# Validate Columns
set_idx=$(awk -F: -v c="$set_col" '{if($1==c) print NR}' "$meta")
where_idx=$(awk -F: -v c="$where_col" '{if($1==c) print NR}' "$meta")

if [[ -z "$set_idx" ]]; then
    zenity --error --text="Column to set ('$set_col') not found."
    exit 1
fi
if [[ -z "$where_idx" ]]; then
    zenity --error --text="Condition column ('$where_col') not found."
    exit 1
fi

# Check PK on Update (Prevent PK change if restricted, or check uniqueness)
# Original script blocked PK update:
is_pk=$(awk -F: -v c="$set_col" '{if($1==c && $3=="PK") print 1}' "$meta")
if [[ "$is_pk" == "1" ]]; then
    zenity --error --text="Cannot update Primary Key column '$set_col'."
    exit 1
fi

# Execute Update
awk -F'|' -v OFS='|' -v sc="$set_idx" -v nv="$new_val" -v wc="$where_idx" -v wv="$where_val" -v op="$op" '
{
    match_row = 0
    if (op == "=" && $wc == wv) match_row=1
    else if (op == "!=" && $wc != wv) match_row=1
    else if (op == ">" && $wc > wv) match_row=1
    else if (op == "<" && $wc < wv) match_row=1
    else if (op == ">=" && $wc >= wv) match_row=1
    else if (op == "<=" && $wc <= wv) match_row=1
    
    if (match_row == 1) {
        $sc = nv
    }
    print $0
}' "$data" > "$data.tmp" && mv "$data.tmp" "$data"

zenity --info --text="Update completed."
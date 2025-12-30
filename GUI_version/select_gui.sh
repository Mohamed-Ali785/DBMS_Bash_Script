#!/bin/bash

DB_path="$1"
# Ask for Table
tb=$(zenity --entry --title="Select Data" --text="Enter Table Name:" 2>/dev/null)
if [[ -z "$tb" ]]; then exit 0; fi

data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

# Check Existence
if [[ ! -f "$meta" || ! -f "$data" ]]; then
    zenity --error --text="Table '$tb' not found." 2>/dev/null
    exit 1
fi

# Get Full Header Row from Meta (e.g., "id|name|age")
full_header=$(awk -F: 'BEGIN{ORS="|"} {print $1}' "$meta" | sed 's/|$//')

# Selection Menu
choice=$(zenity --list \
    --title="Select Options" \
    --column="ID" --column="Method" \
    "1" "Select All" \
    "2" "Select Specific Column" \
    "3" "Select Multiple Columns" \
    "4" "Select With Condition" \
    --hide-column=1 --height=300 2>/dev/null)

if [[ -z "$choice" ]]; then exit 0; fi

# Helper function to display data nicely
# Arguments: $1 = Header String, $2 = Data String
show_table() {
    local hdr="$1"
    local body="$2"
    
    if [[ -z "$body" ]]; then
        zenity --info --text="No results found." 2>/dev/null
    else
        # Combine Header and Body, format as table, and show
        # column -t aligns text based on delimiter (-s '|')
        # Monospace font ensures the alignment looks correct
        { echo "$hdr"; echo "$body"; } | column -t -s '|' | \
        zenity --text-info \
            --title="Result: $tb" \
            --width=600 \
            --height=400 \
            --font="Monospace 12" 2>/dev/null
    fi
}

case $choice in 
    "1") # Select All
        body=$(cat "$data")
        show_table "$full_header" "$body"
        ;;

    "2") # Select Single Column
        col=$(zenity --entry --text="Enter Column Name:" 2>/dev/null)
        if [[ -n "$col" ]]; then
            # Get Index
            idx=$(awk -F: -v c="$col" '{if($1==c) print NR}' "$meta")
            if [[ -z "$idx" ]]; then
                zenity --error --text="Column '$col' not found." 2>/dev/null
                exit 1
            fi
            # Extract Data
            body=$(awk -F'|' -v i="$idx" '{print $i}' "$data")
            # Show with just that column name as header
            show_table "$col" "$body"
        fi
        ;;

    "3") # Select Multiple Columns
        cols=$(zenity --entry --text="Enter Columns (e.g. id,name):" 2>/dev/null)
        if [[ -n "$cols" ]]; then
            # 1. Get Indices
            idxs=$(awk -F: -v c="$cols" 'BEGIN{split(c,a,",")} {for(i in a) if($1==a[i]) printf NR","}' "$meta" | sed 's/,$//')
            
            if [[ -z "$idxs" ]]; then
                zenity --error --text="Invalid columns." 2>/dev/null
                exit 1
            fi

            # 2. Extract Data
            body=$(awk -F'|' -v i="$idxs" 'BEGIN{split(i,a,",")} {for(j=1;j<=length(a);j++) printf "%s|",$a[j]; print ""}' "$data" | sed 's/|$//')
            
            # 3. Format Header (replace comma with pipe)
            custom_header=$(echo "$cols" | tr ',' '|')
            
            show_table "$custom_header" "$body"
        fi
        ;;

    "4") # Select With Condition
        form=$(zenity --forms --title="Filter" --text="WHERE Column=Value" \
            --add-entry="Column Name" \
            --add-entry="Value" 2>/dev/null)
        
        col=$(echo "$form" | cut -d'|' -f1)
        val=$(echo "$form" | cut -d'|' -f2)

        if [[ -n "$col" ]]; then
            idx=$(awk -F: -v c="$col" '{if($1==c) print NR}' "$meta")
            
            if [[ -z "$idx" ]]; then
                zenity --error --text="Column '$col' not found." 2>/dev/null
                exit 1
            fi

            # Filter Rows
            body=$(awk -F'|' -v i="$idx" -v v="$val" '$i==v' "$data")
            
            # Show with full header since we are showing full rows
            show_table "$full_header" "$body"
        fi
        ;;
esac
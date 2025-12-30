#!/bin/bash

# 1. Setup Database Path
DB_path="$1"
if [[ -z "$DB_path" ]]; then
    zenity --error --text="Error: No Database Path provided."
    exit 1
fi

# 2. Get Table Name
tb=$(zenity --entry --title="Select Data" --text="Enter Table Name:")
if [[ -z "$tb" || "$tb" =~ [^a-zA-Z0-9_] ]]; then
    zenity --error --text="Invalid Table Name"
    exit 1
fi

data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

# 3. Check Existence
if [[ ! -f "$meta" || ! -f "$data" ]]; then
    zenity --error --text="Table '$tb' does not exist"
    exit 1
fi

# 4. Selection Menu
choice=$(zenity --list \
    --title="Select Options" \
    --text="Choose selection method:" \
    --column="ID" --column="Method" \
    "1" "Select All" \
    "2" "Select Specific Column" \
    "3" "Select Multiple Columns" \
    "4" "Select With Condition" \
    --hide-column=1 --height=300)

if [[ -z "$choice" ]]; then
    exit 0
fi

# 5. Handle Choices
case $choice in 
    "1") # Select All
        if [[ ! -s "$data" ]]; then
            zenity --info --text="Table is empty."
        else
            # Display raw data in a scrollable text box
            zenity --text-info --title="All Data: $tb" --filename="$data" --width=500 --height=400
        fi
        ;;

    "2") # Select Single Column
        col=$(zenity --entry --title="Select Column" --text="Enter Column Name:")
        
        if [[ -n "$col" ]]; then
            # Find column number
            colnum=$(awk -F: -v col="$col" '{if(col==$1) print NR}' "$meta")
            
            if [[ -z $colnum ]]; then
                zenity --error --text="Column '$col' Not Found"
                exit 1
            fi
            
            # Extract and show
            result=$(awk -F'|' -v c="$colnum" '{print $c}' "$data")
            echo "$result" | zenity --text-info --title="Column: $col" --width=400 --height=400
        fi
        ;;

    "3") # Select Multiple Columns
        cols=$(zenity --entry --title="Multi-Select" --text="Enter Column Names separated by comma (e.g. id,name):")
        
        if [[ -n "$cols" ]]; then
            # Map column names to indices (using your provided logic)
            colnums=$(awk -F: -v cols="$cols" '
                BEGIN { split(cols,c,",") }
                {
                    for(i in c)
                        if($1==c[i])
                            printf NR ","
                }
            ' "$meta" | sed 's/,$//')

            if [[ -z "$colnums" ]]; then
                zenity --error --text="No Valid Columns Found."
                exit 1
            fi

            # Extract data
            result=$(awk -F'|' -v colnums="$colnums" '
            BEGIN {
                split(colnums, c, ",")
            }
            {
                for(i=1;i<=length(c);i++){
                    printf "%s", $c[i]     
                    if(i<length(c)) printf "|" 
                }
                print ""                   
            }' "$data")
            
            echo "$result" | zenity --text-info --title="Selected Columns" --width=500 --height=400
        fi
        ;;

    "4") # Select With Condition
        # Get Column and Value via a Form
        output=$(zenity --forms --title="Filter Data" \
            --text="Enter Filter Criteria" \
            --add-entry="Column Name" \
            --add-entry="Value")
        
        col=$(echo "$output" | cut -d'|' -f1)
        value=$(echo "$output" | cut -d'|' -f2)

        if [[ -z "$col" ]]; then
            exit 1
        fi

        # Find column number
        col_num=$(awk -F: -v c="$col" '{if($1==c) print NR}' "$meta")

        if [[ -z $col_num ]]; then
            zenity --error --text="Column '$col' not found"
            exit 1
        fi

        # Filter data
        result=$(awk -F'|' -v c="$col_num" -v v="$value" '{if($c==v) print $0}' "$data")
        
        if [[ -z "$result" ]]; then
            zenity --info --text="No rows match the condition: $col = $value"
        else
            echo "$result" | zenity --text-info --title="Filtered Results" --width=500 --height=400
        fi
        ;;

    *) 
        exit 0 
        ;;
esac
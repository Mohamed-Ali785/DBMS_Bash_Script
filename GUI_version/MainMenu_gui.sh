#!/bin/bash

DBs="../Databases"
[ ! -d "$DBs" ] && mkdir -p "$DBs"

while true; do
    choice=$(zenity --list \
        --title="Main Menu" \
        --column="ID" --column="Action" \
        "1" "Create Database" \
        "2" "List Databases" \
        "3" "Connect To Database" \
        "4" "Drop Database" \
        "5" "Exit" \
        --hide-column=1 --height=350 --width=400)

    # Handle Cancel/Exit
    if [[ -z "$choice" || "$choice" == "5" ]]; then
        break
    fi

    case $choice in
        "1") DB=$(zenity --entry --title="Create Database" --text="Enter Database Name:")
            if [[ -n "$DB" ]]; then
                # Simple validation for spaces/special chars
                if [[ "$DB" =~ [^a-zA-Z0-9_] ]]; then
                    zenity --error --text="Invalid format. Use alphanumeric or underscore."
                elif [ -d "$DBs/$DB" ]; then
                    zenity --error --text="Database '$DB' already exists!"
                else
                    mkdir "$DBs/$DB"
                    zenity --info --text="Database '$DB' created successfully."
                fi
            fi
            ;;
        "2") if [ -z "$(ls -A $DBs 2>/dev/null)" ]; then
                zenity --info --text="No databases found."
             else
                ls "$DBs" | zenity --list --title="Databases" --column="Database Name" --height=300
             fi
            ;;
        "3")  DB=$(zenity --entry --title="Connect" --text="Enter Database Name to Connect:")
              if [[ -n "$DB" ]]; then
                if [[ -d "$DBs/$DB" ]]; then
                    # Call the Table Menu GUI script
                    source ./tablemenu_gui.sh "$DBs/$DB"
                else
                    zenity --error --text="Database '$DB' not found."
                fi
            fi
            ;;
        "4") DB=$(zenity --entry --title="Drop Database" --text="Enter Database Name to DELETE:")
            if [[ -n "$DB" && -d "$DBs/$DB" ]]; then
                zenity --question --text="Are you sure you want to PERMANENTLY delete '$DB'?"
                if [[ $? -eq 0 ]]; then
                    rm -r "$DBs/$DB"
                    zenity --info --text="Database '$DB' deleted."
                fi
            elif [[ -n "$DB" ]]; then
                 zenity --error --text="Database not found."
            fi
            ;;
    esac
done
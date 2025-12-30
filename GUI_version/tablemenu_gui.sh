#!/bin/bash

DB_PATH=$1

while true; do
    choice=$(zenity --list \
        --title="Table Menu" \
        --text="Connected to: $(basename "$DB_PATH")" \
        --column="ID" --column="Action" \
        "1" "Create Table" \
        "2" "List Tables" \
        "3" "Drop Table" \
        "4" "Insert Into Table" \
        "5" "Select From Table" \
        "6" "Delete From Table" \
        "7" "Update Table" \
        "8" "Back to Main Menu" \
        --hide-column=1 --height=400 --width=400)

    if [[ -z "$choice" || "$choice" == "8" ]]; then
        break
    fi

    case $choice in
        "1") ./create_gui.sh "$DB_PATH" ;;
        "2") ./list_gui.sh "$DB_PATH" ;;
        "3") ./drop_gui.sh "$DB_PATH" ;;
        "4") ./insert_gui.sh "$DB_PATH" ;;
        "5") ./select_gui.sh "$DB_PATH" ;;
        "6") ./delete_gui.sh "$DB_PATH" ;;
        "7") ./update_gui.sh "$DB_PATH" ;;
    esac
done
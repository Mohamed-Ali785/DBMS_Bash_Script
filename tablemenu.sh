#!/usr/bin/bash

DB_PATH=$1

while true
do
    echo "1) Create Table"
    echo "2) List Tables"
    echo "3) Drop Table"
    echo "4) Insert Into Table"
    echo "5) Select From Table"
    echo "6) Delete From Table"
    echo "7) Update Table"
    echo "8) Back"
    read -p "Choose: " choice

    case $choice in
        1) ./create.sh "$DB_PATH" ;;
        2) ./list.sh "$DB_PATH" ;;
        3) ./drop.sh "$DB_PATH" ;;
        4) ./insert.sh "$DB_PATH" ;;
        5) ./select.sh "$DB_PATH" ;;
        6) ./delete.sh "$DB_PATH" ;;
        7) ./update.sh "$DB_PATH" ;;
        8) break ;;
    esac
done
#!/bin/bash

DB_path=$1
tb=$(zenity --entry --title="Drop Table" --text="Enter Table Name to Drop:")

if [[ -z "$tb" ]]; then exit 0; fi

meta="$DB_path/$tb.meta"
data="$DB_path/$tb.data"

if [[ ! -f "$meta" ]]; then
    zenity --error --text="Table '$tb' does not exist."
    exit 1
fi

zenity --question --text="Are you sure you want to drop table '$tb'?\nData will be lost."
if [[ $? -eq 0 ]]; then
    rm -f "$meta" "$data"
    zenity --info --text="Table '$tb' dropped successfully."
fi
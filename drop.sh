#!/usr/bin/bash

DB_path=$1

read -p "Enter Table Name to drop: " tb

if [[ -z "$tb" || "$tb" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid Table Name"
    exit 1
fi

meta="$DB_path/$tb.meta"
data="$DB_path/$tb.data"

if [[ ! -f "$meta" || ! -f "$data" ]]; then
    echo "Table does not exist"
    exit 1
fi

rm -f "$meta" "$data"

echo "Table '$tb' dropped successfully."

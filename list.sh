#!/usr/bin/bash

DB_path=$1

echo "Tables in database 'school':"

tables=$(ls "$DB_path"/*.meta 2>/dev/null)

if [[ -z "$tables" ]]; then
    echo "No Tables Found"
    exit 0
fi

for t in $tables
do
    basename "$t" .meta
done
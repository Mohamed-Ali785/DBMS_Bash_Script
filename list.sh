#!/usr/bin/bash
clear

DB_path=$1

while true
do

path=$(basename "$DB_path")
echo "Tables in database "$path":"

tables=$(ls "$DB_path"/*.meta 2>/dev/null)

if [[ -z "$tables" ]]; then
    echo "No Tables Found"
    exit 0
fi

for t in $tables
do
    basename "$t" .meta
done


read -p "Table Menu?(Y/N): " c
if [[ $c =~ ^[Yy]([Ee][Ss])?$ ]]; then
    clear
    break
else
    clear
    continue
fi
done
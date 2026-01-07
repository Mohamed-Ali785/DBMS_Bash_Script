#!/usr/bin/bash

clear

DB_path=$1

while true
do
read -p "Enter Table Name: " tb
if [[ -z "$tb" || "$tb" =~ [^a-zA-Z0-9_] ]]; then
    echo "Invalid Table Name"
    continue
fi
data="$DB_path/$tb.data"
meta="$DB_path/$tb.meta"

if [[ ! -f $data || ! -f $meta ]]; then
    echo "Table does not exist"
    continue
fi
break
done

echo "1) Select All"
echo "2) Select Colmn"
echo "3) Select multiple colmns"
echo "4) Select With Condition (specific row)"
read -p "Choose: " ch

case $ch in 
	1)	awk -F'|' '{print}' "$data"
   		;;
	2)	read -p "Enter Colmn Name: " col
		colnum=`awk -F: -v col="$col" '{if(col==$1) print NR}' "$meta"`
		if [[ -z $colnum ]]; then
			echo "This Colmn Not Found"
			exit 1
		fi
		awk -F'|' -v c="$colnum" '{print $c}' "$data"
		;;
	3)	read -p "Enter Column Names separated with (,): " cols
		colnums=$(awk -F: -v cols="$cols" '
			BEGIN { split(cols,c,",") }
			{
				for(i in c)
					if($1==c[i])
						printf NR ","
			}
		' "$meta" | sed 's/,$//')

		if [[ -z $colnums ]]; then
			echo "No Valid Colmns Not Found"
			exit 1
		fi;
		awk -F'|' -v colnums="$colnums" '
		BEGIN {
			# split the comma-separated column numbers into an array
			split(colnums, c, ",")
		}
		{
			for(i=1;i<=length(c);i++){
				printf "%s", $c[i]     
				if(i<length(c)) printf "|" 
			}
			print ""                   
		}
		' "$data"
		;;
	4)	read -p "Enter Column Name: " col
		read -p "Enter Value: " value

		col_num=$(awk -F: -v c="$col" '{if($1==c) print NR}' "$meta")

		if [[ -z $col_num ]]; then
			echo "Column not found"
			exit 1
		fi

		awk -F'|' -v c="$col_num" -v v="$value" '{if($c==v) print $0}' "$data"
		;;

	*)	echo "Invalid choice"
    	;;
		
		
esac
while true
do
read -p "Table Menu?(Y/N): " c
if [[ $c =~ ^[Yy]([Ee][Ss])?$ ]]; then
    clear
    break
else
    continue
fi
done
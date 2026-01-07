#!/usr/bin/bash


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
echo "2) Select Column"
echo "3) Select Multiple Columns"
echo "4) Select Column With Condition"
read -p "Choose: " ch

case $ch in 
	1)	clear
		awk -F'|' '{print}' "$data"
   		;;
	2)	while true
		do
		read -p "Enter Column: " col
		if [[ -z "$col" || "$col" =~ [^a-zA-Z0-9_] ]]; then
			echo "Invalid Column Name"
			continue
		fi
		find=$(awk -F: -v coll="$col" '
		{ if(coll==$1)  {print $1; exit;}}' "$meta")
		if [[ -z "$find" ]]; then
			echo "Column Not Found"
			continue
		fi
		colnum=`awk -F: -v col="$col" '{if(col==$1) print NR}' "$meta"`
		clear
		echo "$col"
		echo "----"
		awk -F'|' -v c="$colnum" '{print $c}' "$data"
		break
		done
		;;
	3)	read -p "Enter Column Names Separated with (,): " cols
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
		clear
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
	4)	while true
		do
		read -p "Enter Select Column: " col
		if [[ -z "$col" || "$col" =~ [^a-zA-Z0-9_] ]]; then
			echo "Invalid Column Name"
			continue
		fi
		find=$(awk -F: -v coll="$col" '
		{ if(coll==$1)  {print $1; exit;}}' "$meta")
		if [[ -z "$find" ]]; then
			echo "Column Not Found"
			continue
		fi
		colnum=$(awk -F: -v col="$col" '{if(col==$1) print NR}' "$meta")
		break
		done

		 while true
        do
        read -p "Enter WHERE column: " where_col
        if [[ -z "$where_col" || "$where_col" =~ [^a-zA-Z0-9_] ]]; then
            echo "Invalid Column Name"
            continue
        fi
        type=$(awk -F: -v coll="$where_col" '
        { if(coll==$1)  {print $2; exit;}}' "$meta")
        if [[ -z "$type" ]]; then
            echo "Column Not Found"
            continue
        fi
        break
        done

        while true
        do
        read -p "Enter WHERE value: " where_val
        if [[ -n $where_val && $type == "int" && ! "$where_val" =~ ^[0-9]+$  ]]; then
                    echo "Error: Invalid Integer"
                    continue
        fi
        break
        done

        wherecolnum=$(awk -F: -v col="$where_col" '
        {
            if($1==col){
                print NR
                exit
            }
        }' "$meta")

        if [[ "$type" != "string" ]]; then
            read -p "Choose operator (=, !=, >, <, >=, <=): " op
        else
            read -p "Choose operator (=, !=): " op
        fi
		clear
		echo "$col"
		echo "----"
    	awk -F'|' -v c="$wherecolnum" -v sc="$colnum" -v v="$where_val" -v op="$op" '
        {
            if( (op=="=" && $c==v)   ||
                (op=="!=" && $c!=v)  ||
                (op==">" && $c>v)    ||
                (op=="<" && $c<v)    ||
                (op==">=" && $c>=v)  ||
                (op=="<=" && $c<=v)  )
                print $sc 
        }' "$data"
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
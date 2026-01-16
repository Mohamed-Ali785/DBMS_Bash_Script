#!/bin/bash
clear

DBs="Databases"
if [ ! -d "$DBs" ]; then
    mkdir -p "$DBs"
    echo "Main Databases folder created"
fi

while true
do
echo "Welecome to DBMS Bash Script project"
echo "------------------------------------"
echo "1) Create Database"
echo "2) List Databases"
echo "3) Connect Database"
echo "4) Drop Database"
echo "5) Exit"

read -p "Choose: " choise
clear
case $choise in
	1)      read -p "Enter Database to create: " DB
			if [ -d "$DBs/$DB" ]
			then
				echo "Database already exists"
			else
				mkdir  "$DBs/$DB"
				echo "Database created successfully"
			fi
			;;
    2)	echo "Databases:"
		found=0
		for db in "$DBs"/*/ ; do
   			 [ -d "$db" ] && echo "$(basename "$db")" && found=1
		done
		[ $found -eq 0 ] && echo "No databases found"
		;;
	3)	read -p "Enter Database to connect: " DB
			if [ -d "$DBs/$DB" ]
			then
					echo "connected"
					source tablemenu.sh "$DBs/$DB"
			else
					echo "Database not found"
			fi
		;;
	4)	 read -p "Enter Database Name to drop: " DB
           	 if [ -d "$DBs/$DB" ]; then
               		 rm -r "$DBs/$DB"
               		 echo "Database deleted"
           	 else
                	echo "Database not found"
           	 fi
            	;;

   	 5)  echo "Bye"
            break
        	;;

esac

done

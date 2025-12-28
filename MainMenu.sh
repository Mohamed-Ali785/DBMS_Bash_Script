#!/bin/bash
DBs="Databases"
if [ ! -d "$DBs" ]; then
    mkdir -p "$DBs"
    echo "Main Databases folder created"
fi
PS3="Choose: "
select choise in "Create Database" "List Databases" "Connect to Database" "Drop Database" "Exit"
do
case $REPLY in
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
		       cd "$DBs/$DB"
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

   	 5) 	 echo "Bye"
            	 exit
           	 ;;

esac
done

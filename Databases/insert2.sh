#!/bin/bash
clrar
db="iti_grading_db"

su postgres -c "psql -d $db"

student_id=(22 23  24 25 26)
student_name=("Mohamed","Ali","Ahmed","Sara","Soha")
address=("giza","alex","cairo","aswan","domyat")
email=("mohamed12@iti.com","ali12@iti.com","ahmed12@iti.com","sara12@iti.com","soha12@iti.com")
track_id=(1 1 2 2 3)

for i in "${!student_id[@]}"; do
   sudo -u postgres psql -d iti_grading_db -c " insert into students values("${student_id[$i]}, ${student_name[$i]}, ${address[$i]}, ${email[$i]}, ${track_id[$i]}");
done

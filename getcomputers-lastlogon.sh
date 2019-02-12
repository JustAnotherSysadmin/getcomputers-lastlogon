#!/bin/bash


############################################
#  Read authentication info

# note, the ">&2" at the end of each line redirects the output to STDERR
# as such, this allows one to ./getcomputers.sh > list.txt, and have the prompt
# occur to be seen and not polute the list.txt file.
echo -n "Enter username (username@example.local): " >&2
read USERNAME

echo -n "Enter password: " >&2
read -s PASSWORD

echo "" >&2

############################################
#  Places to query
IFS=""
MYLIST=("Conference Rooms"
        "Desktops"
        "Laptops" 
        "Tablets")

############################################
#  Run the Queries

for MYOU in ${MYLIST[*]}
do

ldapsearch -x -h dc1.example.local -D $USERNAME -w$PASSWORD \
-b"OU=Workstations [${MYOU}],OU=Workstations,OU=Machines,DC=example,DC=local" \
-s sub "(cn=*)" cn lastLogon \
| grep -e 'cn:' -e 'lastLogon' \
| egrep -v '#|^ *$' | awk '{print $2}' \
| awk 'NR%2{printf "%s ",$0;next;}1' \
| awk '{ unixtime = $2 / (10 * 1000 * 1000)-11644473600; printf $1","uni"%.2f\n", unixtime}' \
| awk -F"," '{OFS=","; $2=strftime("%Y-%m-%d %H:%M:%S", $2); print $0}'

done

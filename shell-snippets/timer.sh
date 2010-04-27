#!/bin/bash
#: Title       : Execute-daily scripts in user's home directory
#: Date        : 2010-04-13
#: Author      : Sam Zaydel
#: Version     : 0.1.1
#: Description : Check for daily scripts in user's ~/bin and execute
#: Options     : None
#: Path to file: 
#: Name			: timer.sh

host=$(hostname)
user=$USER

while true
do
    date=$(date +"%I:%M")
    echo "$user@$host  [ $date ]"
    sleep 1m
done
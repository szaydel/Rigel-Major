#!/bin/bash

files_count="10"
counter="1" 
SKIP="0"
#SKIP=$(echo "${RANDOM}" | cut -b1-2)
while [[ $counter -le $files_count ]]
 
do
    echo "Creating file no $counter"
    COUNT=$(echo "${RANDOM}" | cut -b1-3)
    /bin/dd bs=1024 count="${COUNT}" skip="${SKIP}" if=/dev/zero of=file_"${COUNT}"."${counter}"
    counter=$((counter+1))
    done

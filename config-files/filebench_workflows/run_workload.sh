#!/bin/bash

## Name of profile to load
if [[ -z $1 ]]; then
    profile=randomread
else
    profile=$1
fi
##
sizes=(4 8 16 32 64 128)
##test_sizes=(4 8)
for fb_sizeofio in "${sizes[@]}" ; do
## Multiply value by 1024 to get size in bytes
declare -i fb_IOSIZE=$(( $fb_sizeofio * 1024 ))
/opt/tools/fb/bin/filebench <<EOF
load $profile
set \$iosize=$fb_IOSIZE
echo ">>> Setting iosize variable for current run to \$iosize"
run 60
quit
EOF
done

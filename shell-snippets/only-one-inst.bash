#!/bin/bash
MYNAME=$(basename $0)
MYPID=$$
check_for_another_instance ()
{
pgrep "${MYNAME}" | grep -v "${MYPID}" &> /dev/null; RET_CODE=$?
    if [[ "${RET_CODE}" = "0" ]]; then
            printf "%s\n" "Looks like another instance already running."
            return 1
        else
            printf "%s\n" "We are OK."
            return 0    
    fi
}

check_for_another_instance || exit 1

sleep 60
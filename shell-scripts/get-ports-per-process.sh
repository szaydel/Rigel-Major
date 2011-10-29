#!/bin/bash
## Simply run the script with list of processes separated by a space
##
## Script will return output similar to following
##
## Process ID: 25843 * * */ No Open Ports /* * *
## Process ID: 25844 Port Number(s): 52278 2001 3000
## Process ID: 8463 * * */ No Open Ports /* * *
##
##
GREP=/usr/bin/egrep
AWK=/usr/bin/awk
TR=/usr/bin/tr
PF=/usr/bin/pfiles
# PROCS=( $(echo $@ | ${TR} " " "|") )
PROCS=($@)

for PROC_ID in "${PROCS[@]}"
do
  OUT=$( "${PF}" "${PROC_ID}" 2>/dev/null )
  ALL_PORTS=($(echo "${OUT}" | "${GREP}" port | "${AWK}" '{print $NF}' | ${GREP} -v "^0") )

        if [[ "${ALL_PORTS}" = "" ]]; then
                echo "Process ID: ${PROC_ID} * * */ No Open Ports /* * *"
            else
                echo "Process ID: ${PROC_ID} Port Number(s): ${ALL_PORTS[@]}"
        fi
done

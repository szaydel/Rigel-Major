#!/bin/bash
# Script used to identify two most recent kernels, and
# remove any kernels that are older than the two most
# recent kernels
#
###############################################################################
### Step 1 - Set Variables and Create functions
###############################################################################

## RET_CODE=$?
# BKUPDIR=/export/nfs/backups
LOGGER_CMD="/usr/bin/logger -p"
LOGNAME=kern_clean
LOGSDIR=/var/log/${LOGNAME}
MYDATE=$(date +%Y%m%d)
RUN_AS=$(whoami)

## Used in determining if another instance is running
MYNAME=$(basename $0)
MYPID=$$

## Log files, test mode and Debug level
ERRLOG=${LOGSDIR}/error-${MYDATE}-${LOGNAME}.log
INFOLOG=${LOGSDIR}/info-${MYDATE}-${LOGNAME}.log
DEBUG=0
TEST_MODE="Y"

## Redirect stdout to INFOLOG and stderr to ERRLOG
exec 1> "${INFOLOG}"
exec 2> "${ERRLOG}"

DIV=$(printf "%80s" | tr " " "#")

## Set 'APT_CMD' to either test mode or real execution
    if [[ "${TEST_MODE}" = "Y" ]]; then
        ## If test mode is enabled, nothing is removed, hence
        ## the 'dry-run' option
        APT_CMD="/usr/bin/apt-get --dry-run remove"
    else
        APT_CMD="/usr/bin/apt-get remove"
    fi

write_log ()
{
printf "%s\n" "$*" ## >> "${INFOLOG}"
}

# Functions for error control
alert ()
{
# usage: alert <$?> <object>
    if [ "$1" -ne 0 ]; then
       printf "%s\n" "WARNING: $2 did not complete successfully." >&2
       ${LOGGER_CMD} cron.warning "WARNING: $2 did not complete successfully."
       return $1
    else
       printf "%s\n" "INFO: $2 completed successfully."
       ${LOGGER_CMD} cron.notice "INFO: $2 completed successfully."
       return 0
    fi
}

remove_logs ()
{
local FIND_CMD=/usr/bin/find
"${FIND_CMD}" "${LOGSDIR}" -depth -name "[err|info]*" -mtime +30 -delete
}

check_for_another_instance ()
{
pgrep "${MYNAME}" | grep -v "${MYPID}" &> /dev/null; RET_CODE=$?
    if [[ "${RET_CODE}" = "0" ]]; then
            return 1
        else
            return 0
    fi
}

## If another instance of this script already running
check_for_another_instance || exit 1

###############################################################################
### Step 2 - Build Array of old kernels, remove kernels
###############################################################################
kern_array=($(ls /boot/vmlinuz-* | cut -d'-' -f2,3|head -1))

write_log "${DIV}"
##### Fri 31 Dec 2010 06:15:47 PM PST ##### [ Removing Following Kernels ] #####
write_log "##### $(date +%c) ##### [ Removing Following Kernels ] #####"
[[ "${TEST_MODE}" = "Y" ]] && write_log ">>>> Running in Test Mode, -dry-run only <<<<"
write_log "${kern_array[@]}"
write_log "${DIV}"

## Need to write log file with what is being removed

for A in "${kern_array[*]}";
    do dpkg -l \
    | cut -d " " -f3 \
    | egrep --regexp="${A}" \
    | xargs ${APT_CMD}
    RET_CODE=$?
    done

[[ "${DEBUG}" -eq "1" ]] && write_log "Return code from previous command: ${RET_CODE}"
write_log "${DIV}"

## Create an entry in the system log
alert "${RET_CODE}" "Removal of old kernels"

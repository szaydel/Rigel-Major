#!/bin/bash
# Run backintime as part of the run.daily cron job
# This job is normally kicked-off by /etc/cron.daily/execute-user-daily-scripts

###############################################################################
### Step 1 - Set Variables and Create functions
###############################################################################

RET_CODE=$?
BKUPDIR=/export/nfs/backups
LOGSDIR=${BKUPDIR}/logs
MYDATE=$(date +%Y%m%d)
RUN_AS=$(whoami)

## Used in determining if another instance is running
MYNAME=$(basename $0)
MYPID=$$

## Log files and Debug level
ERRLOG=${LOGSDIR}/error-${MYDATE}-${RUN_AS}.log
INFOLOG=${LOGSDIR}/info-${MYDATE}-${RUN_AS}.log
DEBUG=1

# Functions for error control
alert ()
{
# usage: alert <$?> <object>
if [ "$1" -ne 0 ]; then
   echo "WARNING: $2 did not complete successfully." >&2 && logger -p cron.notice "WARNING: $2 did not complete successfully."
   exit $1
   else
   echo "INFO: $2 completed successfully." >&2 && logger -p cron.notice "INFO: $2 completed successfully."
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
### Step 2 - Mount NFS and Run Backup
###############################################################################

## Mount directory to NFS storage
[ ! -d ${BKUPDIR}/${USER} ] && mount ${BKUPDIR} # Need to make sure that we have /export/nfs/backups mounted

## Execute backup job and report on its success or failure
[ ${DEBUG} -eq 0 ] && (nice -n 19 /usr/bin/backintime --backup-job 2> /dev/null; RET_CODE=$?)
[ ${DEBUG} -eq 1 ] && (nice -n 19 /usr/bin/backintime --backup-job 2> ${ERRLOG}; RET_CODE=$?)
[ ${DEBUG} -eq 2 ] && (nice -n 19 /usr/bin/backintime --backup-job > ${INFOLOG} 2> ${ERRLOG}; RET_CODE=$?)

alert ${RET_CODE} "backintime: Backup job for ${RUN_AS}"

###############################################################################
### Step 3 - Clean-up and unmount mounted filesystem
###############################################################################

## At this point we want to clean-up the logs
[ ${DEBUG} -eq 0 ] && (remove_logs 2> /dev/null; RET_CODE=$?)
[ ${DEBUG} -eq 1 ] && (remove_logs 2> ${ERRLOG}; RET_CODE=$?)
[ ${DEBUG} -eq 2 ] && (remove_logs > ${INFOLOG} 2> ${ERRLOG}; RET_CODE=$?)
alert ${RET_CODE} "backintime: Removal of logs for ${RUN_AS}"

# logger -p cron.notice "backintime: Backup job for "${RUN_AS}" finished successfully."

# Once we are done, we will umount NFS mount
while [[ -d ${BKUPDIR}/${USER} ]]
    do
        umount "${BKUPDIR}"
    done

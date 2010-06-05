#!/bin/bash
# Run backintime as szaydel daily

###############################################################################
### Step 1 - Set Variables and Create functions
###############################################################################

RET_CODE=$?
BKUPDIR=/export/nfs/backups
LOGSDIR=${BKUPDIR}/logs
MYDATE=$(date +%Y%m%d)
ERRLOG=${LOGSDIR}/error-${MYDATE}.log
INFOLOG=${LOGSDIR}/info-${MYDATE}.log
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

###############################################################################
### Step 2 - Mount NFS and Run Backup
###############################################################################

## Mount directory to NFS storage
[ ! -d ${BKUPDIR}/${USER} ] && mount ${BKUPDIR} # Need to make sure that we have /export/nfs/backups mounted

## Execute backup job and report on its success or failure
[ ${DEBUG} -eq 0 ] && nice -n 19 /usr/bin/backintime --backup-job 2> /dev/null
[ ${DEBUG} -eq 1 ] && nice -n 19 /usr/bin/backintime --backup-job 2> ${ERRLOG}
[ ${DEBUG} -eq 2 ] && nice -n 19 /usr/bin/backintime --backup-job > ${INFOLOG} 2> ${ERRLOG}

alert ${RET_CODE} "backintime: Backup job for `whoami`"

# logger -p cron.notice "backintime: Backup job for `whoami` finished successfully."
umount ${BKUPDIR} # Once we are done, we will umount NFS mount

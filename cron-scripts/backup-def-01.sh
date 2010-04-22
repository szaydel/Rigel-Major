#!/bin/bash
# Run backintime as szaydel daily
BKUPDIR=/export/nfs/backups
[ ! -d ${BKUPDIR}/${USER} ] && mount ${BKUPDIR} # Need to make sure that we have /export/nfs/backups mounted
nice -n 19 /usr/bin/backintime --backup-job && logger -p cron.notice "backintime: Backup job for `whoami` finished successfully."
umount ${BKUPDIR} # Once we are done, we will umount NFS mount

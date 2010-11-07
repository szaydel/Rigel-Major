#!/bin/bash
# Run restart-squid-proxy.bash as a cron job at night
# This job is normally configured to run at midnight, and meant to
# loop through array 'SERVICE_NAME' and restart all services in
# the array 
###############################################################################
### Step 1 - Set Variables and Create functions
###############################################################################

# RET_CODE=$?
PID_DIR=/var/run
## LOGSDIR=${BKUPDIR}/logs
SERVICE_NAME_ARRAY=( squid )
SERVICE_STATE="1"
MYDATE=$(date +%Y%m%d)
RUN_AS=$(whoami)

## Used in determining if another instance is running
MYNAME=$(basename $0)
MYPID=$$

## Log files and Debug level
ERRLOG=${LOGSDIR}/error-${MYDATE}-${RUN_AS}.log
INFOLOG=${LOGSDIR}/info-${MYDATE}-${RUN_AS}.log
DEBUG=2

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

log_service_state ()
{
if [ "${RET_CODE}" = 0 ]; then
	logger -p cron.info "INFO: Service $1 is currently in a running state."
else 
	logger -p cron.warning "WARNING: Service $1 is not currently in a running state."
fi
}

# remove_logs ()
# {
# local FIND_CMD=/usr/bin/find
# "${FIND_CMD}" "${LOGSDIR}" -depth -name "[err|info]*" -mtime +30 -delete
# }

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

# [[ "${DEBUG}" -ge "2" ]] && sleep 3600

###############################################################################
### Step 2 - Main part of the script, looping through and restarting services
###############################################################################

## Check if service is running and if there is a PID_DIR

for SERVICE_NAME in "${SERVICE_NAME_ARRAY[@]}"
	do
	while [[ "${SERVICE_STATE}" -ne "0" ]]
		do 
			PID_FILE="${PID_DIR}/${SERVICE_NAME}.pid"
			## If the service is running, status will be '0', in which
			## case we will simply issue a simple restart
			/sbin/service "${SERVICE_NAME}" status; RET_CODE=$?
			log_service_state "${SERVICE_NAME}"		
			
			## If pid file still exists, we will remove PID, to make for
			## a cleaner service restart
			if [[ "${RET_CODE}" -eq "0" ]]; then
					/sbin/service "${SERVICE_NAME}" --full-restart
					SERVICE_STATE=$?
					log_service_state "${SERVICE_NAME}"
				else
					[[ -f "${PID_FILE}" ]] && rm -f "${PID_FILE}"
					/sbin/service "${SERVICE_NAME}" start
					SERVICE_STATE=$?
					log_service_state "${SERVICE_NAME}"		
			fi
		done
	done
	
## [[ "${DEBUG}" -ge "2" ]] && (echo Going to sleep; sleep 3600)
# alert ${RET_CODE} "backintime: Backup job for ${RUN_AS}"

###############################################################################
### Step 3 - Clean-up and unmount mounted filesystem
###############################################################################

## At this point we want to clean-up the logs
## [ ${DEBUG} -eq 0 ] && (remove_logs 2> /dev/null; RET_CODE=$?)
## [ ${DEBUG} -eq 1 ] && (remove_logs 2> ${ERRLOG}; RET_CODE=$?)
## [ ${DEBUG} -eq 2 ] && (remove_logs > ${INFOLOG} 2> ${ERRLOG}; RET_CODE=$?)
## alert ${RET_CODE} "backintime: Removal of logs for ${RUN_AS}"

# logger -p cron.notice "backintime: Backup job for "${RUN_AS}" finished successfully."

# Once we are done, we will umount NFS mount
## while [[ -d ${BKUPDIR}/${USER} ]]
##    do
##        umount "${BKUPDIR}"
##    done

#!/usr/bin/bash

## 1 - Check for whether uuid for the event already exists, if so, ignore.

FMDUMP_CMD=/usr/sbin/fmdump
DEBUG=1
BASE=/racktop/fmd-snoop
DATA=${BASE}/data
BIN=${BASE}/bin
RUN=${BASE}/run
HISTTIME="-t4hour"
BLACKLIST=${DATA}/fmd-blklist.log

[[ ${DEBUG} -gt 1 ]] && BLACKLIST=/tmp/fmd-blklist.log || BLACKLIST=${DATA}/fmd-blklist.log

[[ ${DEBUG} -gt 0 ]] && set -x

if [[ ! -d ${DATA} ]]; then
	mkdir ${DATA}
fi

if [[ ${UID} -ne "0" ]]; then
	printf "%s\n" "User not UID == 0, cannot continue."
	exit 1
fi

## Limit query to 180 minutes back
##
FMD_EVENTS=$(${FMDUMP_CMD} ${HISTTIME}|egrep -v 'TIME|Resolved|Repaired'|awk '{print $4}')

## If we cannot find any events, there is no reason for us to linger.
##
if [[ -z ${FMD_EVENTS} ]]; then
	exit 0
fi

## If event has not yet been observed, it will not be in our blacklist,
## as such, we want to collect it and push it to the mothership.
##
for event in ${FMD_EVENTS}; do
	if [[ ! $(grep ${event} ${BLACKLIST}) ]]; then
	
	${FMDUMP_CMD} -Ve -u "${event}" > "${DATA}/fmd-${event}.data"
		[[ ${DEBUG} -gt 0 ]] && touch "${DATA}/created.data.file.$$"
		printf "%s\n" "${event}" >> "${BLACKLIST}"
	fi
done

## Todo => We need a method to push this out. We also need a function to validate connectivity and such.
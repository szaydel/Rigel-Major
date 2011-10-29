#!/usr/bin/bash

# iscsi-client-activity-monitor.sh
#
#
# Copyright 2010 Nexenta Systems, Inc. All rights reserved.

PATH=/usr/sbin:/usr/bin
CLIENT=""
opt_threshold=11

show_usage() {
	cat << END >&2
usage: $0 [-h] [-t threshold] client-IP-address
	-h	# print usage
	-t threshold   # threshold (seconds) for activity monitor (default=${opt_threshold})
END
}

while getopts ht:T name
do
	case $name in

		h) show_usage
		   exit 0
		;;

		t) opt_threshold="${OPTARG}"

		;;

		?|*) show_usage
		     exit 1
		;;

	esac
done
shift $(( $OPTIND - 1 ))


# process remaining parameters
if [[ "$1" > 0 ]]; then
	if [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		CLIENT="$1"
	else
		echo "error: client-IP-address is not an IPv4 address"
		show_usage; exit 1
	fi
	shift
fi

if [[ ! -z "$1" || -z "$CLIENT" ]]; then
	show_usage; exit 1
fi

if [[ "$opt_threshold" =~ ^[0-9]*$ ]]; then
	opt_threshold=$(expr $opt_threshold \* 1000000000)
else
	show_usage; exit 1
fi

# options are known, now run dtrace
dtrace -n '
#pragma D option quiet

inline int THRESHOLD = '$opt_threshold'; /* nanoseconds */

BEGIN {
	n = 0;
	printf("iSCSI target inactivity monitor\n");
	printf("Client IP address %s\n", "'$CLIENT'");
	printf("Inactivity threshold %d seconds\n", THRESHOLD/1000000000);
	printf("Start time %Y\n", walltimestamp);
}

iscsi:::xfer-start
/args[0]->ci_remote == "'$CLIENT'"/
{
	n++;
	start_ts = timestamp + THRESHOLD;
	start_ws = walltimestamp;
}
iscsi:::xfer-start
/!start_active && args[0]->ci_remote == "'$CLIENT'"/
{
	start_active = 1;
	printf("Incoming traffic at %Y\n", walltimestamp);
}

profile:::tick-1sec
/timestamp > start_ts && start_active/
{
	printf("No incoming iSCSI traffic since %Y, current time %Y\n", start_ws, walltimestamp);
	start_active = 0;
}

iscsi:::xfer-done
/args[0]->ci_remote == "'$CLIENT'"/
{
	done_ts = timestamp + THRESHOLD;
	done_ws = walltimestamp;
}
iscsi:::xfer-done
/!done_active && args[0]->ci_remote == "'$CLIENT'"/
{
	done_active = 1;
	printf("Outgoing traffic at %Y\n", walltimestamp);
}

profile:::tick-1sec
/timestamp > done_ts && done_active/
{
	printf("No outgoing iSCSI traffic since %Y, current time %Y\n", done_ws, walltimestamp);
	done_active = 0;
}

iscsi:::login-command
/args[0]->ci_remote == "'$CLIENT'"/
{
	printf("Client %s session %s login at %Y\n", "'$CLIENT'", args[1]->ii_isid, walltimestamp);
}

iscsi:::logout-command
/args[0]->ci_remote == "'$CLIENT'"/
{
	printf("Client %s session %s logout at %Y\n", "'$CLIENT'", args[1]->ii_isid, walltimestamp);
}

profile:::tick-1hour
{
	printf("iSCSI target inactivity monitor status at %Y\n", walltimestamp);
	printf("\tTotal transfers = %d\n", n);
	printf("\tIncoming flow %s\n", start_active ? "active" : "inactive");
	printf("\tLast incoming transfer at %Y\n", start_ws);
	printf("\tOutgoing flow %s\n", done_active ? "active" : "inactive");
	printf("\tLast outgoing transfer at %Y\n", done_ws);
}
'

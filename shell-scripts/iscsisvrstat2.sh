#!/usr/bin/bash
#
# This script measures the latency of NFS server operations.
# The minimum, average, and maximum latency for a server's NFS
# operations is shown in microseconds.
#
# Copyright 2010-2011 Richard Elling
#
# Version 0.3, third pass, do not distribute
#
PATH=/usr/sbin:/usr/bin
operation="all"
opt_time=0
interval=1
count=-1

show_usage() {
	cat << END >&2
USAGE: $0 [-ht] [interval [count]]
	-h	# print usage
	-t	# print timestamp, human readable
	-T	# print timestamp, microseconds since January 1, 1970
END
}

while getopts htT name
do
	case $name in
		h) show_usage; exit 0 ;;
		t) opt_time=1 ;;
		T) opt_time=2 ;;
		?) show_usage; exit 1 ;;
	esac
done
shift $(( $OPTIND - 1 ))

# process remaining parameters
if [[ "$1" > 0 ]]; then
	interval=$1; shift
fi
if [[ "$1" > 0 ]]; then
	count=$1; shift
fi
if [[ ! -z "$1" ]]; then
	show_usage; exit 1
fi

# options are known, now run dtrace
dtrace -n '
inline int INTERVAL = '$interval';
inline int COUNT = '$count';
inline int PRINT_TIME = '$opt_time';

#pragma D option quiet

dtrace:::BEGIN
{
	secs = INTERVAL;
	counts = COUNT;
	printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
		"client", "ops", "ops pending",
        "read ops", "bytes read", "read min", "read avg", "read max",
        "write ops", "bytes write", "write min", "write avg", "write max",
		"nop ops", "nop min", "nop avg", "nop max");
}

iscsi:::xfer-start,
iscsi:::nop-receive
{
	ts[arg1] = timestamp;
	@op_pending[args[0]->ci_remote] = sum(1);
}

iscsi:::xfer-done
/ts[arg1] != 0 && arg8 != 0/
{
	t = timestamp - ts[arg1];
	@op_pending[args[0]->ci_remote] = sum(-1);
	@op_count[args[0]->ci_remote] = count();
	@count_read[args[0]->ci_remote] = count();
	@mintime_read[args[0]->ci_remote] = min(t);
	@avgtime_read[args[0]->ci_remote] = avg(t);
	@maxtime_read[args[0]->ci_remote] = max(t);
	@bytes_read[args[0]->ci_remote] = sum(args[2]->xfer_len);
	ts[arg1] = 0;
}

iscsi:::xfer-done
/ts[arg1] != 0 && arg8 == 0/
{
	t = timestamp - ts[arg1];
	@op_count[args[0]->ci_remote] = count();
	@op_pending[args[0]->ci_remote] = sum(-1);
	@count_write[args[0]->ci_remote] = count();
	@mintime_write[args[0]->ci_remote] = min(t);
	@avgtime_write[args[0]->ci_remote] = avg(t);
	@maxtime_write[args[0]->ci_remote] = max(t);
	@bytes_write[args[0]->ci_remote] = sum(args[2]->xfer_len);
	ts[arg1] = 0;
}

iscsi:::nop-send
/ts[arg1] != 0/
{
	t = timestamp - ts[arg1];
	@op_count[args[0]->ci_remote] = count();
	@op_pending[args[0]->ci_remote] = sum(-1);
	@count_nop[args[0]->ci_remote] = count();
	@mintime_nop[args[0]->ci_remote] = min(t);
	@avgtime_nop[args[0]->ci_remote] = avg(t);
	@maxtime_nop[args[0]->ci_remote] = max(t);
	ts[arg1] = 0;
}

profile:::tick-1sec
{
	secs--;
}

profile:::tick-1sec
/secs == 0/
{
	normalize(@avgtime_write, 1000); normalize(@mintime_write, 1000); normalize(@maxtime_write, 1000);
	normalize(@avgtime_read, 1000); normalize(@mintime_read, 1000); normalize(@maxtime_read, 1000);

	PRINT_TIME == 1 ? printf("%Y\n", walltimestamp) : 1;
	PRINT_TIME == 2 ? printf("%d\n", walltimestamp/1000) : 1;
	printa("%s,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d,%@d\n",
		@op_count, @op_pending,
		@count_read, @bytes_read, @mintime_read, @avgtime_read, @maxtime_read,
		@count_write, @bytes_write,
		@mintime_write, @avgtime_write, @maxtime_write,
		@count_nop, @mintime_nop, @avgtime_nop, @maxtime_nop);

	trunc(@op_count, 0);
	trunc(@count_write, 0); trunc(@avgtime_write, 0); trunc(@mintime_write, 0); trunc(@maxtime_write, 0);
	trunc(@bytes_write, 0);
	trunc(@count_read, 0); trunc(@avgtime_read, 0); trunc(@mintime_read, 0); trunc(@maxtime_read, 0);
	trunc(@bytes_read, 0);
	trunc(@count_nop, 0); trunc(@mintime_nop, 0); trunc(@avgtime_nop, 0); trunc(@maxtime_nop, 0);

	secs = INTERVAL;
	counts--;
}

profile:::tick-1sec
/counts == 0/
{
	exit(0);
}
'

#!/usr/bin/bash
if [[ $# -gt 1 ]]; then
	printf "%s\n" "$@ contains more than one argument. Only one is allowed."
	exit 1
fi

if [[ $# -lt 1 ]]; then
	SYNCTIME=$(printf "%d\n" "$(echo "zfs_txg_synctime_ms::print"|mdb -k)")
elif [[ $1 -eq $1 ]]; then
	SYNCTIME=$1
fi

DELTA=$1
/usr/sbin/dtrace -Cn '
/*
 * Command line arguments
 */

#pragma D option quiet
#pragma D option dynvarsize=4m

inline int MIN_MS = '$SYNCTIME';

dtrace:::BEGIN
{
	printf("Tracing ZFS spa_sync() slower than %d ms...\n", MIN_MS);
	@bytes = sum(0);
	LINES=20;
	line=0;
	exclude = "syspool";
}

 /*
  * Print header
  */
 profile:::tick-1sec
 /line <= 0 /
 {
	/* print header */
	printf("%-20s %-16s %-6s %-6s %-6s %-6s %-6s %-6s %-6s %-6s\n", "Timestamp", "Pool",
		"lat_ms", "t_MB", "r_MB", "w_MB", "t_I/O", "r_I/O", "w_I/O", "throttle");
	line = LINES;
 }


fbt::spa_sync:entry
/!self->start/
{
	throttle = 0;
	in_spa_sync = 1;
	self->start = timestamp;
	self->spa = args[0];
	self->poolname = stringof(self->spa->spa_name);
}

io:::start
/in_spa_sync && self->poolname != exclude/
{
	@io = count();
	@bytes = sum(args[0]->b_bcount);
}

io:::start
/(args[0]->b_flags & B_READ) && in_spa_sync && self->poolname != exclude/
{
	@readio = count();
	@rbytes = sum(args[0]->b_bcount);

}

io:::start
/!(args[0]->b_flags & B_READ) && in_spa_sync && self->poolname != exclude/
{
	@writeio = count();
	@wbytes = sum(args[0]->b_bcount);

}

/* Track I/O throttling events, and aggregate a count of
events per spa_sync event */
::txg_delay:entry 
/in_spa_sync/
{
	/* This is not quite done */
	throttle++;
	@thr = count();

}

fbt::spa_sync:return
/self->poolname != exclude && self->start && (this->ms = (timestamp - self->start) / 1000000) > MIN_MS/
{
	--line;
	normalize(@bytes, 1048576); normalize(@rbytes, 1048576); normalize(@wbytes, 1048576);
	/* printa("%@d MB %@d I/O\n", @bytes, @io); */


	printf("%-20Y %-16s %-6d ", walltimestamp,
	stringof(self->spa->spa_name), this->ms);
	printa("%-6@d %-6@d %-6@d %-6@d %-6@d %-6@d %-6@d\n", @bytes, @rbytes, @wbytes, @io, @readio, @writeio, @thr);
}

fbt::spa_sync:return
{
	self->start = 0; self->spa = 0; in_spa_sync = 0;
	clear(@bytes); clear(@rbytes); clear(@wbytes); 
	clear(@io); clear(@readio); clear(@writeio); clear(@thr);
} '

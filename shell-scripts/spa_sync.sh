#!/usr/bin/bash
#
# Copyright 2012 Sam Zaydel - RackTop Systems
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################
#### DESCRIPTION ##############################################################
###############################################################################
##
## This script wraps around a dtrace script which was written to observe
## IO during SPA sync events. The script will report several key elements
## which should help us better uderstand what the system is doing and the 
## time it takes to complete these events, as well as their frequency.
## By default the script will print to screen only when sync events are taking
## more time than what has been configured on the system for 
## zfs_txg_synctime_ms. By default this will be 1 second, i.e. 1000ms. In order
## to observe all SPA sync events, simply pass `0` as first argument to this
## script on the command line.
##
## We are collecting IO numbers from the io::: provider, which gives us info
## about physical IO.
##
## The following data are collected:
##
## >>> Timestamp 		Timestamp, will print for every line.
## >>> Poolname 		Name of the pool undergoing SPA sync event.
## >>> lat_ms			Amount of time it took to complete the SPA sync event.
## >>> t_MB				Total Megabytes in physical IO, both reads and writes.
## >>> r_MB				Read Megabytes in physical IO.
## >>> w_MB				Write Megabytes in physical IO.
## >>> t_I/O 			Total number of operations performed while in SPA sync.
## >>> r_I/O 			Number of read operations performed while in SPA sync.
## >>> w_I/O  			Number of write operations performed while in SPA sync.
## >>> r_avg(b) 		Average number of bytes per read operation.
## >>> w_avg(b) 		Average number of bytes per write operation.
## >>> throttle			Number of times IO throttle function was entered.
##
###############################################################################


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
	printf("%-20s %-16s %-6s %-6s %-6s %-6s %-6s %-6s %-6s %-8s %-8s %-6s\n", "Timestamp", "Pool",
		"lat_ms", "t_MB", "r_MB", "w_MB", "t_I/O", "r_I/O", "w_I/O", "r_avg(b)", "w_avg(b)", "throttle");
	line = LINES;
 }


fbt::spa_sync:entry
/!self->start/
{
	throttle = 0;
	in_spa_sync = 1;
	self->start = timestamp;
	self->spa = args[0];
	/* Name of the pool */
	this->poolname = stringof(self->spa->spa_name);
}

io:::start
/in_spa_sync && this->poolname != exclude/
{
	@io = count();
	@bytes = sum(args[0]->b_bcount);
}

io:::start
/(args[0]->b_flags & B_READ) && in_spa_sync && this->poolname != exclude/
{
	@readio = count();

	/* Aggregate read bytes collecting a sum of bytes and average IO size */
	@rbytes = sum(args[0]->b_bcount); 
	@avgrbytes = avg(args[0]->b_bcount);

}

io:::start
/!(args[0]->b_flags & B_READ) && in_spa_sync && this->poolname != exclude/
{
	@writeio = count();

	/* Aggregate write bytes collecting a sum of bytes and average IO size */
	@wbytes = sum(args[0]->b_bcount); 
	@avgwbytes = avg(args[0]->b_bcount);

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
/this->poolname != exclude && self->start && (this->ms = (timestamp - self->start) / 1000000) > MIN_MS/
{
	--line;
	/* We normalize bytes to appear as megabytes, as most systems will have large
	sync events and converting from bytes on the fly is less than convinient for most. */
	normalize(@bytes, 1048576); normalize(@rbytes, 1048576); normalize(@wbytes, 1048576);
	/* printa("%@d MB %@d I/O\n", @bytes, @io); */

	printf("%-20Y %-16s %-6d ", walltimestamp,
	stringof(self->spa->spa_name), this->ms);
	printa("%-6@d %-6@d %-6@d %-6@d %-6@d %-6@d %-8@d %-8@d %-6@d\n", @bytes, @rbytes, @wbytes, @io, @readio, @writeio, @avgrbytes, @avgwbytes, @thr);
}

fbt::spa_sync:return
{
	/* Clear all the aggregations and reset variables to 0 before we start over. */
	self->start = 0; self->spa = 0; in_spa_sync = 0; this->ms = 0;
	clear(@bytes); clear(@rbytes); clear(@wbytes); 
	clear(@io); clear(@readio); clear(@writeio); clear(@thr);
} '

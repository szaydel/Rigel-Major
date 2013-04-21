#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
debug 3
set $dir=/volumes/lab9_pool_a/test-data/fb/d00
set $nfiles=300   ## Define number of files in a fileset
set $ndirs=20
# set $meandirwidth=20
set $meanfilesize=15m
## Controls variation in filesizes in a fileset
set $fileszgamma=1500
## Controls whether dir contains subdirs or files
set $dirgamma=0
set $nthreads=16
#set $iosize=8k
set $iosize=4k
set $iosize_4k=4k
set $iosize_8k=8k
set $iosize_32k=32k
set $iosize_128k=128k
set $meanappendsize=16k
set $appendsz=64k
set $myfileset=temp_files
set $memsz=10m
set $writeiters=8
set $preallocpercent=90
set $workingset=0
#set $directio=0
set $four_min=240

define fileset name=$myfileset,path=$dir,filesize=$meanfilesize,entries=$nfiles,dirwidth=$ndirs,filesizegamma=$fileszgamma,prealloc=$preallocpercent,reuse
define process name=rand-rw,instances=1
{
## Operations : Random Read at 4k, 8k, 32k, 128k
  thread name=random_read_thread,memsize=5m,instances=$nthreads
  {
    flowop read name=rand-read-4k-1,filesetname=$myfileset,iosize=$iosize_4k,random,workingset=$workingset
    flowop read name=rand-read-8k-1,filesetname=$myfileset,iosize=$iosize_8k,random,workingset=$workingset
    flowop read name=rand-read-32k-1,filesetname=$myfileset,iosize=$iosize_32k,random,workingset=$workingset
    flowop read name=rand-read-128k-1,filesetname=$myfileset,iosize=$iosize_128k,random,workingset=$workingset
  }

## Operations : Random Write at 4k, 8k, 32k, 128k
  thread name=random_write_thread,memsize=5m,instances=$nthreads
  {
    flowop write name=rand-write-4k-1,filesetname=$myfileset,iosize=$iosize_4k,random,workingset=$workingset
    flowop write name=rand-write-8k-1,filesetname=$myfileset,iosize=$iosize_8k,random,workingset=$workingset
    flowop write name=rand-write-32k-1,filesetname=$myfileset,iosize=$iosize_32k,random,workingset=$workingset
    flowop write name=rand-write-128k-1,filesetname=$myfileset,iosize=$iosize_128k,random,workingset=$workingset
  }

## Operations : Random Read DirectIO at 4k, 8k, 32k, 128k
  thread name=random_read_thread_directIO,memsize=5m,instances=$nthreads
  {
    flowop read name=rand-read-4k-2,filesetname=$myfileset,iosize=$iosize_4k,random,workingset=$workingset,directio,dsync
    flowop read name=rand-read-8k-2,filesetname=$myfileset,iosize=$iosize_8k,random,workingset=$workingset,directio,dsync
    flowop read name=rand-read-32k-2,filesetname=$myfileset,iosize=$iosize_32k,random,workingset=$workingset,directio,dsync
    flowop read name=rand-read-128k-2,filesetname=$myfileset,iosize=$iosize_128k,random,workingset=$workingset,directio,dsync
  }

## Operations : Random Write DirectIO at 4k, 8k, 32k, 128k
  thread name=random_write_thread_directIO,memsize=5m,instances=$nthreads
  {
    flowop write name=rand-write-4k-1-dio,filesetname=$myfileset,iosize=$iosize_4k,random,workingset=$workingset,directio,dsync
    flowop write name=rand-write-8k-1-dio,filesetname=$myfileset,iosize=$iosize_8k,random,workingset=$workingset,directio,dsync
    flowop write name=rand-write-32k-1-dio,filesetname=$myfileset,iosize=$iosize_32k,random,workingset=$workingset,directio,dsync
    flowop write name=rand-write-128k-1-dio,filesetname=$myfileset,iosize=$iosize_128k,random,workingset=$workingset,directio,dsync
  }
}

echo "Random RW Version modified by SZ from packaged version"
usage "Usage: set \$dir=<dir>         defaults to $dir"
usage "       set \$filesize=<size>   defaults to $filesize"
usage "       set \$iosize=<value>    defaults to $iosize"
usage "       set \$nthreads=<value>  defaults to $nthreads"
usage "       set \$workingset=<value>  defaults to $workingset"
usage "       set \$directio=<bool>   defaults to $directio"
usage "       run runtime (e.g. run 60)"
run 240
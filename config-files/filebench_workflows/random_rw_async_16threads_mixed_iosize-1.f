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
set $dir=/mnt/d00
#set $dir=/volumes/lab9_pool_a/test-data/fb/d00
set $nfiles=100   ## Define number of files in a fileset
set $ndirs=10
set $meandirwidth=20
#set $meanfilesize=4g
set $meanfilesize=10m
set $filesize=$meanfilesize
## Controls variation in filesizes in a fileset
set $fileszgamma=1500
## Controls whether dir contains subdirs or files
set $dirgamma=0
set $nthreads=32
#set $iosize=8k
set $iosize=4k
set $iosize_4k=4k
set $iosize_8k=8k
set $iosize_16k=16k
set $iosize_32k=32k
set $iosize_64k=64k
set $iosize_128k=128k
set $meanappendsize=16k
set $appendsz=64k
set $filename=rand_rw_AzxeWas1Nz
set $myfileset=$filename
set $memsz=10m
set $writeiters=8
set $preallocpercent=60
set $workingset=0
set $directio=0
set $four_min=240
set $iters=2

define fileset name=$myfileset,path=$dir,filesize=$meanfilesize,entries=$nfiles,dirwidth=$ndirs,filesizegamma=$fileszgamma,prealloc=$preallocpercent,reuse
##
define process name=random_write-1,instances=1
{
## Operations : Random Read at 4k, 8k, 32k, 64k, 128k
  thread name=random-aio-1,memsize=10m,instances=$nthreads
  {
    flowop openfile name=Rand_open_4k-1,filename=$myfileset,directio=$directio,fd=1
    flowop aiowrite name=Rand_Wr_4k-1,filename=$myfileset,iosize=$iosize_4k,random,workingset=$workingset,iters=$iters,directio=$directio,fd=1
    #flowop aiowait name=Rand_wait_4k-1,target=Rand_Wr_4k-1
    flowop closefile name=Rand_close_4k-1,fd=1
    ##
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

log "Path: $dir, Filesize: $filesize, IO Size: $iosize"
run 300

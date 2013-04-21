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
# Copyright 2009 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
debug 3
set $dir=/mnt/d00
#set $dir=/volumes/lab9_pool_a/test-data/fb/d00
set $nfiles=10   ## Define number of files in a fileset
set $ndirs=0
# set $meandirwidth=20
set $meanfilesize=4g
set $filesize=$meanfilesize
## Controls variation in filesizes in a fileset
set $fileszgamma=1500
## Controls whether dir contains subdirs or files
set $dirgamma=0
set $nthreads=32
#set $iosize=8k
#set $iosize=4k
set $iosize_4k=4k
set $iosize_8k=8k
set $iosize_16k=16k
set $iosize_32k=32k
set $iosize_64k=64k
set $iosize_128k=128k
set $meanappendsize=16k
set $appendsz=64k
#set $myfileset=temp_files
#set $date=$(DS)
set $filename=rand_rw_AzxeWas1Nz
set $myfileset=$filename
set $memsize=10m
set $writeiters=8
set $preallocpercent=90
#set $workingset=0
set $workingset=$filesize
set $directio=0
set $four_min=240
set $iters=2

define file name=$filename,path=$dir,size=$filesize,prealloc,reuse,paralloc

define process name=RandomRdProcess,instances=1
{
  thread name=RandomRdThread,memsize=$memsize,instances=$nthreads

  {
    flowop read name=Random_Rd_Flowop-01,filename=$filename,iosize=$iosize,random,workingset=$workingset,directio=$directio
    
    ## flowop read name=RandReadFlowop-8k,filename=$filename,iosize=$iosize_8k,random,workingset=$workingset,directio=$directio
    
    ## flowop read name=RandReadFlowop-16k,filename=$filename,iosize=$iosize_16k,random,workingset=$workingset,directio=$directio
  }

}


echo "Basic Random Read Version 1.0 personality successfully loaded"
usage "Usage: set \$dir=<dir>         defaults to $dir"
usage "       set \$filesize=<size>   defaults to $filesize"
usage "       set \$iosize=<value>    defaults to $iosize"
usage "       set \$nthreads=<value>  defaults to $nthreads"
usage "       set \$workingset=<value>  defaults to $workingset"
usage "       set \$directio=<bool>   defaults to $directio"
usage "       run runtime (e.g. run 60)"

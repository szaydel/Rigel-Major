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
set $nfiles=10000   ## Define number of files in a fileset
set $ndirs=20
# set $meandirwidth=20
set $meanfilesize=1m
## Controls variation in filesizes in a fileset
set $fileszgamma=250
## Controls whether dir contains subdirs or files
set $dirgamma=4000
set $nthreads=16
# set $iosize=1m
#set $iosize=8k
set $iosize=4k
set $meanappendsize=16k
set $appendsz=64k
set $myfileset=temp_files
set $memsz=10m
set $writeiters=8
set $preallocpercent=50


define fileset name=$myfileset,path=$dir,size=$meanfilesize,entries=$nfiles,dirwidth=$ndirs,filesizegamma=$fileszgamma,prealloc=$preallocpercent,reuse

define process name=filereader,instances=1
{
  thread name=filerandreadthread,memsize=$memsz,instances=$nthreads
  {
    flowop createfile name=createfile_1,filesetname=$myfileset,fd=1
    flowop write name=write_rand_4k_io_size_1,filesetname=$myfileset,iosize=$iosize,workingset=10m,random,fd=1
    flowop closefile name=aioclosefile_1,fd=1
    flowop openfile name=openfile_1,filesetname=$myfileset,fd=2
    flowop read name=read_rand_4k_io_size_1,filesetname=$myfileset,iosize=$iosize,workingset=1g,random,fd=2
    flowop closefile name=aioclosefile_2,fd=2
    # flowop createfile name=createfile_2,filesetname=$myfileset,fd=2
    # flowop aiowrite name=write_rand_4k_io_size_1,filesetname=$myfileset,iosize=$iosize,workingset=1m,random,fd=2,srcfd=1
    #flowop aiowait name=aiowait_1,target=aiowrtfile1

    #flowop appendfilerand name=append_rand_4k_io_size_1,iosize=$io_four_k,fd=0
    #flowop statfile name=statfile_1,filesetname=$myfileset,iters=8,fd=0
    #flowop deletefile name=deletefile_1,filesetname=$myfileset
    #flowop closefile name=closefile_1,fd=1
    #flowop closefile name=closefile_2,fd=2
  }
  #   thread name=filerandreadthread,memsize=$memsz,instances=$nthreads
  # {
  #   flowop createfile name=createfile_2,filesetname=$myfileset,fd=1
  #   flowop write name=write_rand_4k_io_size_2,filesetname=$myfileset,iosize=$io_four_k,workingset=1m,random,fd=1
  #   flowop read name=read_rand_4k_io_size_2,filesetname=$myfileset,iosize=$io_four_k,workingset=1m,random,fd=1
  #   flowop openfile name=openfile_2,filesetname=$myfileset,fd=2
  #   flowop appendfilerand name=append_rand_4k_io_size_2,iosize=$io_four_k,fd=1
  #   flowop statfile name=statfile_2,filesetname=$myfileset,iters=8,fd=1
  #   flowop deletefile name=deletefile_2,filesetname=$myfileset
  #   flowop closefile name=closefile_2,fd=1
  # }
}

echo  "Sam's Sandbox learning personality successfully loaded"
usage "Usage: set \$dir=<dir>"
usage "       set \$meanfilesize=<size>     defaults to $meanfilesize"
usage "       set \$nfiles=<value>      defaults to $nfiles"
usage "       set \$nthreads=<value>    defaults to $nthreads"
usage "       set \$meanappendsize=<value>  defaults to $meanappendsize"
usage "       set \$iosize=<size>  defaults to $iosize"
usage "       set \$meandirwidth=<size> defaults to $meandirwidth"
usage "       run runtime (e.g. run 60)"
run 120
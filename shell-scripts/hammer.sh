#!/usr/bin/bash
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
# Copyright 2012 Nexenta Systems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Written by Sam Zaydel
#
# Purpose of the script is quite simple. We want to stress test disks and 
# need a meaningful way to do it before a system is rolled out.
# At the moment other tools are primarily designed to do performance
# testing v. a burn-in test and all we need is a way of stressing disks.
# We are using xargs and pushing a list of all disks in the the array we
# build from /dev/rdsk/* devices, which is quite dumb at the moment and 
# does not distinguish between syspool and ssds, etc, but it is an OK
# start. Once we have this worked out and ready to introduce writes we will
# have to be far more careful about what disks we are writing to.
# Needed to add a trap to make sure that we are not running dd's out of
# control after leaving the script.
################################################################################
### Step 1 : Define Global variables for use in the script #####################
################################################################################
scriptname=$0 # First argument is shell command (as in C)
total_args=$#  # Number of args, not counting $0

## If no command line arguments are provided, we bail, have to have one.
##
if [ "${total_args}" -eq 0 ]; then
    printf "[%s] %s\n" "${scriptname}" "could not start due to a missing required argument."
    printf "%s\n" "Error: Please enter minimum number of minutes to run the test."
    exit 1
fi
    
debug=1  ## Debug flag is enabled while testing to prevent anything stupid
flag=~/stopdd.flag  ## This flag may be useful if we need to abort prematurely
date_cmd=/usr/bin/date
dd_cmd=/usr/bin/dd
awk_cmd=/usr/bin/awk
##sed_cmd=/usr/bin/sed
##sort_cmd=/usr/bin/sort
rm_cmd=/usr/bin/rm
grep_cmd=/usr/bin/grep
egrep_cmd=/usr/bin/egrep
hddisco_cmd=/usr/bin/hddisco
xargs_cmd=/usr/bin/xargs
basename_cmd=/usr/bin/basename
devfs_cmd=/usr/sbin/devfsadm
pkill_cmd=/usr/bin/pkill
tr_cmd=/usr/bin/tr
zpool_cmd=/usr/sbin/zpool
is_syspool=''   ## Variable is used in the case statement to validate syspool
rd_counter=0
wr_counter=0
min_devsize=1500301910016
min_devsize=10737418240
minutes=${1}
seconds=$(( ${minutes} * 60 ))

################################################################################
### Revision Notes: ############################################################
################################################################################
# 03-16-2012 added a more functional failure capture and reporting
# xxxxxxxxxx return codes added to read and write functions
# xxxxxxxxxx adjusted trap to make more functional
# xxxxxxxxxx checking number of disks in the array, and if less than one bail
# xxxxxxxxxx added a function to print convinient parting status
# 03-18-2012 made the array of disks section more compact by reducing duplicate
# xxxxxxxxxx code between debug and non-debug modes
# xxxxxxxxxx added function to validate disk size, testing for >10GB disks in
# xxxxxxxxxx debug mode, and >1TB disks in production mode
# 03-20-2012 syspool detection is using a better regex pattern
################################################################################
### Step 1a : Build Functions called later throughout the script ###############
################################################################################

function linesep ()
{
## Print a line separator 80-characters long
printf "%80s\n" | ${tr_cmd} ' ' '='
}

function newline ()
{
printf "%s\n"
}

function cleanup () {
    ${rm_cmd} -f ${flag}
    return 0
}

function exit_script() 
{
    linesep
    if [[ -f ${flag} ]]; then
        printf "[INFO] Flag file %s indicting premature termination was detected." "${flag}" 
    fi
    ## Got this far, means we are done and time to exit
    printf "[INFO] Script ${scriptname} finished.\n[INFO] Time Elapsed: %d seconds.\n" "$(( $(${date_cmd} +%s) - ${start_t} ))"
    printf "[INFO] Number of Read tests %d done, Number of Write tests %d done.\n" "${rd_counter}" "${wr_counter}"
    linesep
    return 0
}

## If something goes wrong, we should be running this function
## and returning a meaningful error message along with a line number
## in the script where we called die()
##
function die()
{
echo >&2 -e "\n[ERROR] $@\n"; cleanup; 
exit_script
exit 1
}

function validate_syspool () {

    ## Return state of syspool, which should contain list of disks.
    newline
    ${zpool_cmd} status syspool

    while [ -z "${is_syspool}" ]
        do
            newline
            printf "%s\n" "[CRIT] Please confirm that these disks are your syspool."
            printf "%s    >>> %s <<<\n" "Are these your syspool drives?" "${syspool[@]}"
            newline
            printf "%s" "Continue, or stop? [Y|N] "; read is_syspool
            newline

            case ${is_syspool} in

                Y|y ) ## We are good to go here and are returning 0
                    return 0
                    ;;

                * ) ## Anything other than Y|y is not expected, bailing
                    printf "%s\n" "[CRIT] Something must be wrong. Exiting."
                    return 1
                    ;;
            esac
        done
}

## Taking AG's suggestion of testing against disk size instead of looking
## to exclude based on partial WWN of well-known solid state disks.
##
function check_devsize () 

{
    local devid=${1}
    local dev_size=''
    ## If we are in debug mode, using smaller device size, because we are
    ## testing on virtual hardware with much, much smaller disks
    ##
    [[ ${debug} -eq 1 ]] && min_devsize=10737418240

    ## Here we obtain the size of the device ala hddisco,
    ## which, if broken, will result in this script failing.
    ##
    dev_size=$( ${hddisco_cmd} -d ${devid}|${awk_cmd} '/^size / {print $2}' )

    if [[ ${dev_size} -lt ${min_devsize} ]]; then
        [[ ${debug} -eq 1 ]] \
        && printf "[DEBUG] Device: %s does not qualify, smaller than %d bytes.\n" "${devid}" "${min_devsize}"
        return 1
    else
        return 0
    fi
}
################################################################################
### Step 1b : Build variables and arrays used later in the script ##############
################################################################################

## Set our start time here. We need to know when we started to make
## the rest of the math work.
##
start_t=$(${date_cmd} +%s)

## We do not want any rogue dd's going on, so need to trap them and cleanup.
##
trap 'printf "\n%s\n" "[WARN] Signal trapped. Cleaning-up."; \
touch ${flag}; ${pkill_cmd} dd; ${pkill_cmd} ${scriptname}; \
echo Last Return Code: $?' 1 2 3 15

## Just so we have some sense of what is being cleaned-up, we want to collect
## device links that are being removed.
##
dev_cleanup_log=/tmp/devfsadm-$(hostname)-$(${date_cmd} +%s).log

## This is our syspool array and should only contain syspool disks
##
syspool=( $(${zpool_cmd} status syspool|${awk_cmd} '/c[[:digit:]]t[[:alnum:]]+d[[:alnum:]]+s0/ {print $1}') )

## If for whatever reason we cannot determine syspool, we should bail now
##
[[ ${#syspool[@]} -lt 1 ]] && die "[Line ${LINENO}] Unable to detect syspool, cannot continue."

## only basenames are included in the array `/dev/rdsk` is stripped to reduce
## size of non-unique argument components in the array.
##

## Here, we start out with a raw array of devices, but end-up building
## `array_disks` array after checking each device in this against minimum
## device size. If the device is smaller than minimum acceptable size,
## we are assuming it is not a normal disk and do not continue further.

## This is run if the debug flag is set and we are testing the functionality
## Please, add at least one disk from syspool to this array to make
## sure that in fact we are correctly excluding the disk(s).
## In the example below first disk in list is a syspool disk.
##
if [[ ${debug} -eq 1 ]]; then
    arr_disks_raw=( c1t0d0s0 c1t10d0s0 c1t11d0s0 )
else
    arr_disks_raw=( $(ls /dev/rdsk/*s0|${xargs_cmd} -n1 ${basename_cmd}) )
fi

for dev in ${arr_disks_raw[@]}; do
    check_devsize ${dev//s0/}
    if [[ $? -eq 0 ]]; then
        arr_disks+=( ${dev} )
    fi
    done

echo "[DEBUG] Before Array change: ${arr_disks[@]}"
## We adjust the final array to not include any disks in syspool
for disk in "${syspool[@]}"; do 
    arr_disks=( ${arr_disks[@]//${disk}*/} )
done
echo "[DEBUG] After Array change: ${arr_disks[@]}"

## This many disk entries in the array, if less than one, we die.
arr_disk_len=${#arr_disks[@]}
[[ ${arr_disk_len} -lt 1 ]] && die "[Line ${LINENO}] No disks were detected, cannot continue."

## We validate that in fact the disks that we think are in syspool
## are indeed in the syspool, if not matched, we exit.
##
validate_syspool || die "[Line ${LINENO}] Unable to validate drives in syspool."

## If we fail above, there is no sense in defining any more functions below.
## Purely for performance reasons we are not creating the below functions.

################################################################################
### Step 1c : Build functions that will do brunt of the work  ##################
################################################################################

## Lets clean-up the device links to make sure that we are not reading
## stale links and observing errors from `dd`.
##
function clean_dev_links() {
    ${devfs_cmd} -Cv > ${dev_cleanup_log} 2>&1; ret_code=$?
    return ${ret_code}
}

## This is our read test function, it is incomplete as hell
## for now, but should suffice as a first shot at this.
##
function run_read_test() {
    local fn=${FUNCNAME}
    local rrt_count=${1}

    if [[ ${debug} -eq 1 ]]; then
        ## If in debug mode, lets make for a much smaller test
        local dd_args="bs=128k iflag=sync count=1000"
    else
        local dd_args="bs=128k iflag=sync"
    fi
    ## local dd_args="bs=128k oflag=sync"
    ## Choosing this option over the second option commented out below
    ## to avoid using `tr` unnecessarily, but leaving in as a option.
    printf "[INFO] Test [%s] Started. Function %s entered.\n[INFO] Arguments to [dd] are: %s\n" "${rrt_count}" "${fn}" "${dd_args}"
    for disk in "${arr_disks[@]}"; do echo ${disk}; done | xargs -n1 -i -t -P${arr_disk_len} ${dd_cmd} if=/dev/rdsk/{} of=/dev/null ${dd_args};
    
    local ret_code=$?   ## Return code for previous command, may not always work.
    printf "[INFO] Test [%s] Stopped. Leaving function %s.\n\n" "${rrt_count}" "${fn}"
    return ${ret_code}
}

function run_write_test() {
    local fn=${FUNCNAME}
    local wwt_count=${1}

    if [[ ${debug} -eq 1 ]]; then
        ## If in debug mode, lets make for a much smaller test
        local dd_args="bs=128k oflag=sync count=1000"
    else
        local dd_args="bs=128k oflag=sync"
    fi
    ## local dd_args="bs=128k oflag=sync"
    ## Choosing this option over the second option commented out below
    ## to avoid using `tr` unnecessarily, but leaving in as a option.
    printf "[INFO] Test [%s] Started. Function %s entered.\n[INFO] Arguments to [dd] are: %s\n" "${wwt_count}" "${fn}" "${dd_args}"
    for disk in "${arr_disks[@]}"; do echo ${disk}; done | xargs -n1 -i -t -P${arr_disk_len} ${dd_cmd} if=/dev/urandom of=/dev/rdsk/{} ${dd_args};

    local ret_code=$?   ## Return code for previous command, may not always work.
    printf "[INFO] Test [%s] Stopped. Leaving function %s.\n\n" "${wwt_count}" "${fn}"
    return ${ret_code}
}

################################################################################
### Step 2 : Main body of the script running functions above ###################
################################################################################

## If there is still an old flag in place that was used to stop
## the test prematurely we need to clean it up first.
if [[ -f ${flag} ]]; then

    printf "\nRemoving old flag that was seemingly left over. >>> %s\n\n" "${flag}"
    cleanup
fi

## Let's clean-up stale device links and exit before anything else happens
## if for some reason we get anything other than `0` as return from function.
##
clean_dev_links || die "[Line ${LINENO}] Unable to correctly remove stale Device links."

## We cheat here, and reset the start time. The first time we set it to make
## sure that early exit due to possibly incorrect syspool disks, etc. would
## return correct run time of the script. If we got this far, we reset the start
## time to reflect accurate run time of `actual` tests.
##
start_t=$(${date_cmd} +%s)

## For the moment we are conservative and only doing a read test,
## as an example of what we can do, if sufficient, we will add
## write test to this script, which will be destructive.
##
while [[ $(( ${start_t} + ${seconds} )) > $(${date_cmd} +%s) && ! -f ${flag} ]]; do

    if [[ ! -f ${flag} ]]; then
        rd_counter=$(( rd_counter + 1 ))
        run_read_test ${rd_counter} || die "[Line ${LINENO}] Test failed, possibly due to a trap or missing device."
    fi

    if [[ ! -f ${flag} ]]; then    
        wr_counter=$(( wr_counter + 1 ))
        run_write_test ${wr_counter} || die "[Line ${LINENO}] Test failed, possibly due to a trap or missing device."
    fi
done

## Will need to add some exit criteria later, for the moment this will do.
exit_script && exit $?

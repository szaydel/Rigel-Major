#!/usr/bin/bash
## First stab at a disk thrashing utility
##
##
##
##
scriptname=$0 # First argument is shell command (as in C)
total_args=$#  # Number of args, not counting $0

if [ "$#" -eq 0 ]; then
    printf "%s\n" "Error: Please enter minimum number of minutes to run the test."
    exit 1
fi
    
debug=1      ## Debug flag is enabled while testing to prevent anything stupid
flag=~/stopdd.flag
date_cmd=/usr/bin/date
dd_cmd=/usr/bin/dd
##awk_cmd=/usr/bin/awk
##sed_cmd=/usr/bin/sed
##sort_cmd=/usr/bin/sort
rm_cmd=/usr/bin/rm
grep_cmd=/usr/bin/grep
egrep_cmd=/usr/bin/egrep
xargs_cmd=/usr/bin/xargs
basename_cmd=/usr/bin/basename
devfs_cmd=/usr/sbin/devfsadm
rd_counter=0
wr_counter=0
minutes=${1}
seconds=$(( ${minutes} * 60 ))
## Just so we have some sense of what is being cleaned-up, we want to collect
## device links that are being removed.
##
dev_cleanup_log=/tmp/devfsadm-$(hostname)-$(${date_cmd} +%s).log

## only basenames are included in the array `/dev/rdsk` is stripped to reduce
## size of non-unique argument components in the array.
##
    if [[ ${debug} -eq 1 ]]; then 
        arr_disks=( c1t10d0s0 c1t11d0s0 )
    else
        arr_disks=( $(ls /dev/rdsk/*s0|${xargs_cmd} -n1 ${basename_cmd}) )
    fi

arr_disk_len=${#arr_disks[@]}       ## This many disk entries in the array

start_t=$(${date_cmd} +%s)
duration=''     ## How many hours do we want to run this, convert to seconds

function cleanup () {
    ${rm_cmd} -f ${flag}
    return 0
}

## Lets clean-up the device links to make sure that we are not reading
## stale links and observing errors from `dd`.
##

function clean_dev_links() {
    ${devfs_cmd} -Cv > ${dev_cleanup_log} 2>&1
}

## This is our read test function, it is incomplete as hell
## for now, but should suffice as a first shot at this.
function run_read_test() {

    local rrt_count=${1}

    if [[ ${debug} -eq 1 ]]; then
        local dd_args="bs=128k iflag=sync count=10000"
    else
        local dd_args="bs=128k iflag=sync"
    fi
    ##local dd_args="bs=128k oflag=sync"
    ##opt 1
    printf "### Test [%s] Started args to /dd/ are: %s ###\n" "${rrt_count}" "${dd_args}"
    for disk in "${arr_disks[@]}"; do echo ${disk}; done | xargs -n1 -i -t -P${arr_disk_len} ${dd_cmd} if=/dev/rdsk/{} of=/dev/null ${dd_args}
    printf "### Test [%s] Stopped. Leaving function. ###\n\n" "${rrt_count}"
    ##opt 2
    # echo "${myarr[@]}"|tr ' ' '\n' | xargs -n1 -i -t -P10 echo dd if=/dev/rdsk/{} of=/dev/null bs=1k count=4

    return 0
}

## If there is still an old flag in place that was used to stop
## the test prematurely we need to clean it up first.
if [[ -f ${flag} ]]; then

    printf "\nRemoving old flag that was seemingly left over. >>> %s\n\n" "${flag}"
    cleanup
fi

## For the moment we are conservative and only doing a read test,
## as an example of what we can do, if sufficient, we will add
## write test to this script, which will be destructive.
while [[ $(( ${start_t} + ${seconds} )) > $(${date_cmd} +%s) && ! -f ${flag} ]]; do
    rd_counter=$(( rd_counter + 1 ))
    run_read_test ${rd_counter}
    
done

printf "Script $0 finished.\nTime Elapsed: %s Number of Read tests: %s\n" " $(( $(${date_cmd} +%s) - ${start_t} ))" "${rd_counter}"

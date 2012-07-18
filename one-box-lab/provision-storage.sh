#!/bin/bash

progname=$(basename $0)
version='1.2'
debug=1
cannot_continue=""

ZFS_CMD=/usr/sbin/zfs

#!/bin/sh

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_file=""
verbose=0

function show_help () {
	usage="Usage:
	${progname} [-h] -s <pool/dataset> -t <pool/dataset> [-b -c  ] -- program to calculate the answer to life, the universe and everything

	where:
    	-h    Show this help text
    	-b    Perform a backup operation of dataset
    	-c    Perform a restore operation from backup
    	-s    Source dataset from which we are cloning or backing-up
    	-t    Target dataset to which we are cloning or backing-up
    	-T    Test if lab environment already present, supply dataset name, i.e. poolname/dataset
    "

	echo "${usage}" >&2
}

while getopts "bch?l:vs:t:T:" opt; do

    case "$opt" in
        h|\?)
            show_help
            exit 0
        ;;

        v)  verbose=1
        ;;

        l) ## Name of the lab environment, will be used as snapshot name
			lab_name="${OPTARG}"
		;;
        
        b) ## Backup to archive
			operation=backup
		;;

		c) ## Restore from archive
			operation=clone
		;;

        s)	source_from="${OPTARG}"
			source_pool_name=${source_from%%\/*} # <= name of source pool, no slashes
			source_dataset_name=${source_from#*\/} # <= name of source dataset, minus pool
		;;

		t)	target_to="${OPTARG}"
			target_pool_name=${target_to%%\/*} # <= name of source pool, no slashes
			target_dataset_name=${target_to#*\/} # <= name of source dataset, minus pool
		;;

		T)	test_if_exist="${OPTARG}"
		;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

## echo "operation='${operation}' source_from='${source_from}' target_to='${target_to}' verbose=$verbose, output_file='$output_file', Leftovers: $@"


## Quick sanity checks to make sure we have required elements
##


if [[ ! -z "${test_if_exist}" ]]; then
	
	if [[  $(zfs list -H -oname "${test_if_exist}" ) ]]; then
		RET_CODE=0
	else
		RET_CODE=1
	fi
	
	exit "${RET_CODE}"
fi

if [[ -z "${source_from}" ]]; then 
	printf "[ERROR] %s\n" "Source was not given; however, it is required!";
	cannot_continue=1
fi


if [[ -z "${target_to}" ]] ; then
	printf "[ERROR] %s\n" "Target was not given; however, it is required!";
	cannot_continue=1
fi

if [[ -z "${operation}" ]]; then
	printf "[ERROR] %s\n" "Operation to perform not given; however, it is required!";
	cannot_continue=1
fi

if [[ "${cannot_continue}" -eq "1" ]]; then
	printf "%s\n" ""
	show_help
	exit 1
fi

## Set default lab name if one was not supplied
##
if [[ -z "${lab_name}" ]]; then
	lab_name=latest
fi

## Backup Operation

function cleanup_zfs_destination() {
	##
	## Create snapshot of ZFS filesystem
	## Arguments required are:
	## 1st argument == name of dataset including name of pool
	## 2nd argument == name of snapshot to be created

	local dataset_name="$1"
	local snapshot_name="$2"

	if [[ "${debug}" -gt "1" ]]; then

		echo /usr/sbin/zfs list -t snapshot "${dataset_name}@${snapshot_name}"
		echo /usr/sbin/zfs destroy -r "${dataset_name}/${source_dataset_name}@${snapshot_name}"
		RET_CODE=0
	
	## If there is already a snapshot available at the destination, 
	## we are blowing it away, because we are assuming that it is stale.
	## Operation is not safe and we need to keep this in mind.

	else
		[[ "${debug}" -gt "0" ]] && set -x

		local snapshot_name_on_dest=${dataset_name}/${source_dataset_name}@${snapshot_name}

		/usr/sbin/zfs list -t snapshot "${snapshot_name_on_dest}"

		if [[ $(/usr/sbin/zfs list -t snapshot "${snapshot_name_on_dest}") ]]; then
		
			printf "[INFO] %s\n" "Snapshot ${snapshot_name_on_dest} exists, removing."

			/usr/sbin/zfs destroy -r "${snapshot_name_on_dest}"
			RET_CODE=$?
		else
			## There is nothing to do if snapshot on destination does not exist
			RET_CODE=0
		fi

	fi

	[[ "${debug}" -gt "0" ]] && set +x
	return "${RET_CODE}"
}


function create_zfs_snapshot() {
	##
	## Create snapshot of ZFS filesystem
	## Arguments required are:
	## 1st argument == name of dataset including name of pool
	## 2nd argument == name of snapshot to be created

	local dataset_name="$1"
	local snapshot_name="$2"

	if [[ "${debug}" -gt "1" ]]; then

		echo /usr/sbin/zfs snapshot -r "${dataset_name}@${snapshot_name}"
		echo /usr/sbin/zfs list -t snapshot "${dataset_name}@${snapshot_name}"
		RET_CODE=0
	
	else
		[[ "${debug}" -gt "0" ]] && set -x
		/usr/sbin/zfs snapshot -r "${dataset_name}@${snapshot_name}"
		RET_CODE=$?

		/usr/sbin/zfs list -t snapshot "${dataset_name}@${snapshot_name}"
	fi

	[[ "${debug}" -gt "0" ]] && set +x
	return $?
}

function send_zfs_snapshot() {

	function send_operation() {
		/usr/sbin/zfs send -R "${dataset_name}@${snapshot_name}" | zfs recv -Fduv "${target_name}"
		return $?
	}

	local dataset_name="$1"
	local snapshot_name="$2"
	local target_name="$3"

	if [[ "${debug}" -gt "1" ]]; then

		echo "/usr/sbin/zfs send -r "${dataset_name}@${snapshot_name}" | zfs recv -Fduv "${target_name}" "
	else
		[[ "${debug}" -gt "0" ]] && set -x
		
		## We need to make sure that we successfully sent our snapshot
		send_operation; recv_succeeded=$?
		[[ "${debug}" -gt "0" ]] && set +x
	fi

	## If the Send operation was successful, we need to do the following:
	## 1) List snapshot, to confirm that it was in fact created
	## 2) Remove snapshot from the source

	if [[ "${recv_succeeded}" -eq "0" ]]; then
		RET_CODE=0
	else
		printf "[ERROR] %s\n" "Failure sending snapshot to ${target_name}"
		RET_CODE=1
	fi
		
		printf "%s\n" "Cleaning-up snapshot ${dataset_name}@${snapshot_name}"

		[[ "${debug}" -gt "0" ]] && set -x
		/usr/sbin/zfs destroy -r "${dataset_name}@${snapshot_name}"

		## Do not enable below during testing. At some point we will want to
		## remove the actual dataset on the source.
		##
		## /usr/sbin/zfs destroy -r "${dataset_name}"


	[[ "${debug}" -gt "0" ]] && set +x
	return "${RET_CODE}"	
}

if [[ "${operation}" == "backup" ]]; then

	cleanup_zfs_destination "${target_to}" "${lab_name}"; RET_CODE=$?

	[[ "${RET_CODE}" -eq "1" ]] && (printf "[ERROR] %s\n" "Something happened during clean-up."; exit 1)

	## Create snapshot on <poolname>/<datasetname>
	create_zfs_snapshot "${source_from}" "${lab_name}"

	## Send snapshot to another dataset for safe keeping
	send_zfs_snapshot "${source_from}" "${lab_name}" "${target_to}"
fi

if [[ "${operation}" == "restore" ]]; then

	send_zfs_snapshot "${source_from}" "${lab_name}" "${target_to}"
fi


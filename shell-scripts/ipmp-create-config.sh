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
# Copyright 2011 Nexenta Systems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Written by Sam Zaydel
#
# Purpose of the script is to generate configuration files in a format required
# to enable IPMP functionality. While this script will work with just one int.
# IPMP is by its nature designed for multipathing IP, and makes little sense
# if only one interface is going to be added to the group. This is fine, only
# on a short-term basis, as well as for testing, but not practical otherwise.
#
# Script will not overwrite your existing configuration, but it is a good idea
# to make a backup of existing configuration before replacing any existing
# /etc/hostname.<interface> configuration files.
# Consider taking a snapshot of the appliance, that way if there are issues you
# can easily revert to earlier snapshot.
#
################################################################################
### Step 1 : Define Global variables for use in the script #####################
################################################################################
CAT=/usr/bin/cat
CUT=/usr/bin/cut
TEE=/usr/bin/tee
TR=/usr/bin/tr
AWK=/usr/bin/awk
SED=/usr/bin/sed
SORT=/usr/bin/sort
RM=/usr/bin/rm
GREP=/usr/bin/grep
EGREP=/usr/bin/egrep
DLADM=/usr/sbin/dladm
EXEC_DIR=$(dirname $0)
EXPR=/usr/bin/expr
IPMP_IF_ARRAY=()		## Array with all interfaces to add to IPMP group
IPMP_ALIASES_ARRAY=()	## Array of data IPs to be assigned to IPMP interface
IPMP_GRP_NAME=data0		## Name of actual IPMP group, not all that critical
IPMP_IF_NAME="${IPMP_GRP_NAME}"	## Name of ipmp interface to be created
COMMON_MTU=1500
TEST_IP_SUBNET_M="255.255.255.0"
DATA_IP_SUBNET_M="255.255.255.0"
IPMP_DATA_ADDR_COUNT=0
WORKDIR=/tmp			## By default, all config files will go here, not /etc
PROBE_BASED=""
VERS=1.0.5
################################################################################
### Revision Notes: ############################################################
################################################################################
# 2011/07/15 :  Modified ipmp MTU configuration, to only set MTU once on the
# 				entire group, as that should propagate through the entire set of
#				aliases on the ipmp interface.
# 2011/07/15 :  Revised wording on input of number of additional data interfaces
# 2011/07/22 :  Enhancement 1 - Match ipmp_group_name to
# 				/etc/hostname.ipmp_group_name, instead of using hostname.ipmp0
#				Need to make IPMP Probe-based failure optional, and link-based
#				the default option, instead of probe-based being default.
# 2011/07/27 :	Modified script to account for, and report aggregates correcly.
#				Changed IPMP group naming to match hostname.interface name to
#				the name of the group. If there is no trailing ordinal in group
#				name, we will add a zero, if there is one, we will not add zero
#				Changed IPMP Probe-based function check to warn about using
#				probe-based detection, and the possible consequences.
#
#
################################################################################
### Step 1a : Build Functions called later throughout the script ###############
################################################################################
linesep ()
{
## Print a line separator 80-characters long
printf "%80s\n" | ${TR} ' ' '='
}

newline ()
{
printf "%s\n"
}

# loginfo ()
# {
# ## Prefix output with loginfo for any lines that should print to screen
# ## and to log file at the same time
# ## At the moment we are not using this function - perhaps later

#     local NOW=$(date "+%F %T")
#     local LINE="$@"
#     printf "%s\n" "${NOW} ${LINE}" | ${TEE} -a "${INFO_LOG}"
# }

early_exit ()
{
local T=$1
newline
printf "%s\n" "[CRITICAL] Abandoned Wizard early, due to issues with ${T}."
exit 1
}

test_file_access ()
{
local W=$1

if [[ ! -d "${W}" ]]; then
		newline
		printf "%s\n" "[CRITICAL] Unable to set Work Directory to ${W}. It does not exist."
		local RET_CODE=1
elif [[ ! -w "${W}" ]]; then
		newline
		printf "%s\n" "[CRITICAL] Write Access to ${W} is not permitted, unable to continue."
		local RET_CODE=0
	else
		newline
		printf "%s\n" "[CRITICAL] Write Access to ${W} is permitted, able to continue."
		local RET_CODE=0
fi
return "${RET_CODE}"
}

cleanup_old_confs ()
{
## To make sure that we are not appending anything to old configs
## we should do a cleanup of old files if we find them.
## Create array based on values passed into the function
local IF_LIST=( "$@" )
local yes_no=""

## We loop through each element in the array until
## we are out of elements
for IF in "${IF_LIST[@]}"
	do
		local FILE=${WORKDIR}/hostname.${IF}
		if [[ -f "${FILE}" ]]; then
			while [ -z "${yes_no}" ]
				do
					newline
					printf "%s\n" "[WARN] Found existing file: ${FILE}" \
					"We can continue and REMOVE this file, or we can STOP here!"
					printf "%s" "Continue, and remove? [Y|N] "; read yes_no
					newline

					case "${yes_no}" in
						Y|y)
							linesep
							printf "%s\n" ">>> Removing file: ${FILE} <<<"
							${RM} -f "${FILE}"
							linesep
							;;
						N|n)
							printf "%s\n" ">>> Exiting Wizard, due to existing config files <<<"
							local RET_CODE=1
							break
							;;
						  *)
						  	yes_no=""
						  	;;
					esac

				done
			yes_no=""
			# echo "---MARK---" "${FILE}"	## Used for debugging loop
		fi
	done

return "${RET_CODE:-0}"
}

write_conf_file ()
{
################################################################################
## Generic function used to write generated lines into files ###################
################################################################################
##	We send collected dataout to config files /${WORKDIR}/hostname.<interface>
local FILE_CONTENTS=$1
local IF_N=$2
# local TEE_OPTS=$3
local CONFIG_FILE_PATH=${WORKDIR}/hostname.${IF_N}
#printf "%s\n" "|====== Adding Contents: ======|"
#printf "%s\n" "${FILE_CONTENTS}" | ${TEE} ${TEE_OPTS} "${CONFIG_FILE_PATH}"
printf "%s\n" "${FILE_CONTENTS}" >> "${CONFIG_FILE_PATH}"
}

define_basic_defaults ()
{
################################################################################
## We define some sane defaults and adjust as necessary ########################
################################################################################
printf "%s\n" "*** IPMP Configuration Generator script verion ${VERS} started. ***" \
"We will first set some defaults, which we will then use throughout the script." \
"We will not overwrite existing config files."
newline

printf "%s\n%s" "[*] Directory where new config files will go (Default is ${WORKDIR})" \
"New Path, or Enter for default: "; read N_WORKDIR
WORKDIR="${N_WORKDIR:=$WORKDIR}"
test_file_access "${WORKDIR}" || return 1
newline

printf "%s\n%s" "[*] MTU for all interfaces in IPMP Group (Default is ${COMMON_MTU})" \
"New MTU, or Enter for default: "; read N_COMMON_MTU
COMMON_MTU="${N_COMMON_MTU:=$COMMON_MTU}"
newline

printf "%s\n%s" "[*] Subnet Mask for Test IPs (Default is ${TEST_IP_SUBNET_M})" \
"New Mask, or Enter for default: "; read N_TEST_IP_SUBNET_M

## We need to test subnet mask to make sure it is valid, but only
## in the case where it has been changed from default
[ ! -z "${N_TEST_IP_SUBNET_M}" ] && test_ip_address_is_valid "${N_TEST_IP_SUBNET_M}"
local VALIDATE_TEST_IP_SUBNET_M=$?

if [[ ! -z "${N_TEST_IP_SUBNET_M}" && "${VALIDATE_TEST_IP_SUBNET_M}" -ne 0 ]]; then
	while [[ "${VALIDATE_TEST_IP_SUBNET_M}" -ne 0 ]]
		do
			N_TEST_IP_SUBNET_M=""
			printf "%s\n%s" "Your Subnet Mask Appears to be invalid." "New Mask: "; read N_TEST_IP_SUBNET_M
			test_ip_address_is_valid "${N_TEST_IP_SUBNET_M}"; local VALIDATE_TEST_IP_SUBNET_M=$?
		done
fi

TEST_IP_SUBNET_M="${N_TEST_IP_SUBNET_M:=$TEST_IP_SUBNET_M}"
newline

printf "%s\n%s" "[*] Subnet Mask for Data IPs (Default is ${DATA_IP_SUBNET_M})" \
"New Mask, or Enter for default: "; read N_DATA_IP_SUBNET_M

## We need to test subnet mask to make sure it is valid, but only
## in the case where it has been changed from default
[ ! -z "${N_DATA_IP_SUBNET_M}" ] && test_ip_address_is_valid "${N_DATA_IP_SUBNET_M}"
local VALIDATE_DATA_IP_SUBNET_M=$?

if [[ ! -z "${N_DATA_IP_SUBNET_M}" && "${VALIDATE_DATA_IP_SUBNET_M}" -ne 0 ]]; then
	while [[ "${VALIDATE_DATA_IP_SUBNET_M}" -ne 0 ]]
		do
			N_DATA_IP_SUBNET_M=""
			printf "%s\n%s" "Your Subnet Mask Appears to be invalid." "New Mask: "; read N_DATA_IP_SUBNET_M
			test_ip_address_is_valid "${N_DATA_IP_SUBNET_M}"; local VALIDATE_DATA_IP_SUBNET_M=$?
		done
fi

DATA_IP_SUBNET_M="${N_DATA_IP_SUBNET_M:=$DATA_IP_SUBNET_M}"
newline

printf "%s\n%s" "[*] IPMP Groups Requires a name (Default is ${IPMP_GRP_NAME})" \
"Group name, or Enter for default: "; read N_IPMP_GRP_NAME
## If we have a custom group name, let's make sure that there is an ordinal
## at the end of the group name, as that's what we have to have, in order
## for the IPMP hostname.groupname file to be valid

if [ ! -z "${N_IPMP_GRP_NAME}" ]; then
	## Variable ${ISINT} should contain a digit, if groupname was created
	## with a trailing ordinal, i.e. 0-9
	ISINT=$(echo $(${EXPR} match "${N_IPMP_GRP_NAME}" '.*\([0-9]\)'))
	if [ $(echo "${ISINT}"|${GREP} [0-9]) ]; then
			IPMP_GRP_NAME="${N_IPMP_GRP_NAME}"
		else
			## If we cannot locate an ordinal at the end of the groupname,
			## we want to make sure that we add one, since IPMP interface names
			## have to end with an ordinal
			IPMP_GRP_NAME="${N_IPMP_GRP_NAME}0"
	fi
	## We need to make sure to update the interface name for the IPMP interface,
	## if we are changing the ${IPMP_GRP_NAME} variable
	IPMP_IF_NAME="${IPMP_GRP_NAME}"
fi
## Below line was replaced with the nested 'if' statement above
## IPMP_GRP_NAME="${N_IPMP_GRP_NAME:=$IPMP_GRP_NAME}"
newline

printf "%s\n%s" "[*] At least one Data IP interface is required. How many additional IP's will you require? (Default is ${IPMP_DATA_ADDR_COUNT})" \
"Total Number of IP Aliases (i.e. 1, 2, 3), or Enter for default: "; read N_IPMP_DATA_ADDR_COUNT
IPMP_DATA_ADDR_COUNT="${N_IPMP_DATA_ADDR_COUNT:=$IPMP_DATA_ADDR_COUNT}"
newline

printf "%s\n" "### Working Directory: ${WORKDIR}" \
"### Setting Test IP Mask: ${TEST_IP_SUBNET_M}" \
"### Setting Data IP Mask: ${DATA_IP_SUBNET_M}" \
"### Setting IPMP Group Name: ${IPMP_GRP_NAME}" \
"### Sum of IPMP DATA IPs: $(( ${IPMP_DATA_ADDR_COUNT} + 1))"
newline
}

test_ip_address_is_valid ()
{
################################################################################
## We need to pass IPs through validation of format ############################
################################################################################
##
## We will use this function inside other functions to make sure
## that IP entries supplied to us make sense, and meet our expected format

local IP_ADDR=$1
local NUM_OF_OCTETS=$(echo "${IP_ADDR}" | ${TR} '.' ' '| ${AWK} '{print NF}')

## Test 1 - Validate that # of octets is as exepected, if not we fail and return 1
if [[  "${NUM_OF_OCTETS}" -ne 4 ]]; then
	printf "%s\n" "[WARN] IP Address does not meet a standard of xxx.xxx.xxx.xxx. Check Number of Octets!"
	return 1
fi

## Test 2 - Validate that none of the octets is > 255, if not we fail and return 1
for octet in $(echo "${IP_ADDR}" | ${AWK} -F . '{print $1, $2, $3, $4}')
do
	if (( octet > 255 )); then
		printf "%s\n" "[WARN] One or more octets is/are > than 255. Value of each octet must be < than 255!"
		return 1
	fi
done
return 0
}

ipmp_interfaces_array ()
{
################################################################################
## We need to collect Interface Information and build array ####################
################################################################################

local counter="0"
local IF_IPMP=""
# local IF_LIST=( $(${DLADM} show-phys -po LINK | ${GREP} -v "aggr") )

printf "%s\n" "We need to select interfaces which will comprise IPMP group [${IPMP_GRP_NAME}]"
printf "%s\n" "" "All Currently Present Interfaces:" \
"$(${DLADM} show-link -o LINK,MTU,STATE)" ""

while [[ -z "${IPMP_IF_ARRAY[@]}" ]]
    do
        printf "%s\n%s" "Please enter space separated list of Interfaces" "Interfaces (i.e. e1000g0,e1000g1,etc.): "; read IF_IPMP
        newline
 		for IF in ${IF_IPMP}; do IPMP_IF_ARRAY+=("${IF}"); done

	## We need to make sure that each interface entry actually corresponds
	## to existing physical interface
	for IF in "${IPMP_IF_ARRAY[@]}"
		do
			## Need to be sure we are not checking for physical interfaces, rather logical
			if [[ $( ${DLADM} show-link "${IF}" 2>/dev/null ) ]]; then
			# if [[ $( ${DLADM} show-phys "${IF}" 2>/dev/null ) ]]; then
					printf "%s\n" "[GOOD] Interface ${IF} exists on system"
					${DLADM} show-link "${IF}"
					newline
				else
					## Catch any interfaces that do not exist, and break out of the loop
					printf "%s\n" "[BAD] Interface ${IF} does not exist, please try again!"
					newline
					IPMP_IF_ARRAY=()
					break
			fi
		done
	done

return "${RET_CODE:-0}"
}

use_probe_based_fail_detect ()
{
################################################################################
## We need to check for probe-based failure usage   ############################
################################################################################
## Probe-based failure detection is problematic when there are not enough
## targets defined to test against
## In many cases storage networks will not have a defined gateway, and so
## targets have to be explicitly defined, else probes will not work correctly
## In a cluster situation we want to be absolutely certain that heads do not
## use each other as targets, since this defeats the purpose of IPMP and failure
## of one node will cause IPMP group(s) to fail on the other node
local yes_no=""
printf "%s\n%s" "Are you planning to use Probe-based Failure detection?" "Answer [Y|N]: "; read yes_no
newline

	while [[ -z "${PROBE_BASED}" ]]
		do
			case "${yes_no}" in
				Y|y)
				printf "%s\n" \
"
********************************************************************************
***** WARNING * WARNING * WARNING * WARNING * WARNING * WARNING * WARNING  *****
********************************************************************************
* IPMP Probe-based failure detection mechanism should be enabled only if you   *
* understand what you are doing. Failure to correctly configure Probe-based    *
* failure detection may result in serious issues with functionality of the     *
* IPMP group. As such, please ONLY enable it if you are certain about expected *
* results and what is necessary to configure it correctly.                     *
********************************************************************************
***** WARNING * WARNING * WARNING * WARNING * WARNING * WARNING * WARNING  *****
********************************************************************************
"
					printf "%s\n" "If you are uncertain about Probe-based failure, please hit <Control-C> now, and start over." \
					"" \
					"We will next ask for a test IP for each interface, which is required for Probe-based detection."

					PROBE_BASED=Y
					;;
				N|n|*)
					printf "%s\n" "Probe-based failure detection will not be enabled!"
					PROBE_BASED=N
					;;
			esac
		done
}

ipmp_targets_configure ()
{
local TOTAL_INTERFACES=${#IPMP_IF_ARRAY[@]}
local IF_INDEX=1
local yes_no

for IF in ${IPMP_IF_ARRAY[@]}
	do
		if [[ "${PROBE_BASED}" = "Y" ]]; then
				local TEST_IP=""
			else
				## If Probe based detection is not used, we can simply set test IPs to
				## all zeroes which effectively disables probe-based detection
				local TEST_IP="0.0.0.0"
				# printf "%s\n" "group ${IPMP_GRP_NAME} ${TEST_IP} -failover netmask ${TEST_IP_SUBNET_M} up" | ${TEE} "${WORKDIR}/hostname.${IF}"
				write_conf_file "group ${IPMP_GRP_NAME} ${TEST_IP} -failover netmask ${TEST_IP_SUBNET_M} mtu ${COMMON_MTU} up" ${IF}
		fi

		## echo "${#IPMP_IF_ARRAY[@]} ${IF}" ## For testing purposes
		while [[ -z "${TEST_IP}" ]]
			do
				newline
				printf "%s\n%s" "Please enter Test IP Address to be used for Interface ${IF}" "Interfaces (i.e. 10.10.10.1): "; read TEST_IP
				newline

				## We first validate that we indeed have a properly formed IP Address
				test_ip_address_is_valid "${TEST_IP}"; local VALIDATE_IP=$?
				if [[ "${VALIDATE_IP}" -eq 1 ]]; then
						local TEST_IP=""
					else
						## Assuming IP Address has been successfully validated we write
						## new config file
						# linesep
						# printf "%s\n" "group ${IPMP_GRP_NAME} -failover ${TEST_IP} netmask ${TEST_IP_SUBNET_M} up" | ${TEE} "${WORKDIR}/hostname.${IF}"
						# linesep
						write_conf_file "group ${IPMP_GRP_NAME} ${TEST_IP} -failover netmask ${TEST_IP_SUBNET_M} mtu ${COMMON_MTU} up" ${IF}
				fi

				if [[ -z "${TEST_IP}" ]]; then
					newline
					printf "%s\n" "It appears that you did not enter a valid test address, do you still want Probe-based failure detection?"
					printf "%s" "Answer [Y|N]: "; read yes_no
					case "${yes_no}" in
						Y|y)
							local TEST_IP=""
							;;
						N|n)
							local TEST_IP="0.0.0.0"
							;;
					esac
				fi
		done
		local TEST_IP=""
	done
}

ipmp_interface_configure ()
{
local IPMP_ALIAS_COUNTER=${IPMP_DATA_ADDR_COUNT}
local IF_INDEX=1
local IPMP_PRI_DATA_ADDR=""
local IPMP_ALIAS_ADDR=""
local yes_no=""

while [[ -z "${IPMP_PRI_DATA_ADDR}" ]]
	do
		printf "%s\n%s" "Please enter Primary Data IP Address (i.e. 10.10.10.1)" ">>> "; read IPMP_PRI_DATA_ADDR
		newline

		## We first validate that we indeed have a properly formed IP Address
		test_ip_address_is_valid "${IPMP_PRI_DATA_ADDR}"; local VALIDATE_IP=$?
		if [[ "${VALIDATE_IP}" -eq 1 ]]; then
				local IPMP_PRI_DATA_ADDR=""
			else
				## Assuming IP Address has been successfully validated we write
				## new config file
				# linesep
				# printf "%s\n" "ipmp group ${IPMP_GRP_NAME} ${IPMP_PRI_DATA_ADDR} netmask ${DATA_IP_SUBNET_M} up" | ${TEE} "${WORKDIR}/hostname.${IPMP_IF_NAME}"
				# linesep
				## We want to keep the MTU setting on the IPMP group interface, not indv.
				## interfaces under the ipmp0 umbrella
				write_conf_file "ipmp group ${IPMP_GRP_NAME} mtu ${COMMON_MTU}" ${IPMP_IF_NAME}

				write_conf_file "    ${IPMP_PRI_DATA_ADDR} broadcast + netmask ${DATA_IP_SUBNET_M} up" ${IPMP_IF_NAME} "-a"
		fi
done

## We exhust the count of IP Aliases down to zero before we stop
## running this loop. Count tells us how many aliases we are making
while [[ "${IPMP_ALIAS_COUNTER}" -gt 0 ]]
 	do
		printf "%s\n%s" "Please enter Alias Data IP Address (i.e. 10.10.10.1)" ">>> "; read IPMP_ALIAS_ADDR
		newline
		## We first validate that we indeed have a properly formed IP Address
		test_ip_address_is_valid "${IPMP_ALIAS_ADDR}"; local VALIDATE_IP=$?
		if [[ "${VALIDATE_IP}" -eq 1 ]]; then
				local IPMP_ALIAS_ADDR=""
			else
				## Assuming the IP is properly formed, we are adding it to the
				## array of IP aliases over which we are later going to loop and
				## result will be generation of ${WORKDIR}/hostname.${IPMP_IF_NAME}
				IPMP_ALIASES_ARRAY+=("${IPMP_ALIAS_ADDR}")
				local IPMP_ALIAS_ADDR=""
				IPMP_ALIAS_COUNTER=$(( IPMP_ALIAS_COUNTER - 1 ))
		fi
 	done

## Loop over all values in IPMP Aliases Array and write-out lines
## appending them to hostname.ipmpX file
for IP_ADDR in "${IPMP_ALIASES_ARRAY[@]}"
	do
		# printf "%4s%s\n" "" "addif ${IP_ADDR} netmask ${DATA_IP_SUBNET_M} mtu ${COMMON_MTU} up"  | ${TEE} -a "${WORKDIR}/hostname.${IPMP_IF_NAME}"
		write_conf_file "    addif ${IP_ADDR} broadcast + netmask ${DATA_IP_SUBNET_M} up"  ${IPMP_IF_NAME} "-a"
	done
}

report_configs_created ()
{
local IF_LIST=( "$@" )
printf "*** Wizard Completed! Generated config files in ${WORKDIR} ***"
newline
newline
for IF in "${IF_LIST[@]}"
	do
		local FILE=${WORKDIR}/hostname.${IF}
		linesep
		printf "%s\n" "### Contents of File: ${FILE}"
		linesep
		${CAT} "${FILE}"
		newline
	done

}
################################################################################
### Step 2 : Begin Main body of the script #####################################
################################################################################
define_basic_defaults || early_exit "Directory Access"
ipmp_interfaces_array
use_probe_based_fail_detect
cleanup_old_confs "${IPMP_IF_ARRAY[@]}" "${IPMP_IF_NAME}" || early_exit "Removing previous Config Files"
ipmp_targets_configure
ipmp_interface_configure
report_configs_created "${IPMP_IF_ARRAY[@]}" "${IPMP_IF_NAME}"
exit 0
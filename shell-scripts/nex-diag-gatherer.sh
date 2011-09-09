#!/usr/bin/nmc
# Purpose: Simplify gathering of logs from NexentaStor Appliances
# when mailer configuration is not working, or not setup.
#
# Author: Sam Zaydel
# Copyright 2011 Nexenta Systems, Inc. 
#
nmc_cmd=$(which nmc)
hdd_cmd="/usr/bin/hddisco"
fma_faulty_cmd="/usr/sbin/fmadm faulty"
fmdump_cmd="/usr/sbin/fmdump"
iostat_cmd="/usr/bin/iostat"
cfgadm_cmd="/usr/sbin/cfgadm"
devfsadm_cmd="/usr/sbin/devfsadm"
kstat_cmd="/usr/bin/kstat"
mv_cmd="/usr/bin/mv"
host_n=$(hostname)
ts=$(date +%Y%m%d)
tail_cmd="/usr/bin/tail"
zp_cmd="/usr/sbin/zpool"
un="/usr/bin/uname"
WORK_DIR="/tmp"
PRE=${WORK_DIR}/${host_n}
GZ_OUT_F=${host_n}-syst-bundle-${ts}.tar.gz
ZPOOL_ARR=( $(zpool list -H -o name) )
FILES_ARR=()
_CFGADM="1"		## Enable cfgadm data gathering
_FMA="1"		## Enable fmadm data gathering
_FMD="1"		## Enable fmdump data gathering
_KST="1"		## Enable stat data gathering
_ZHIST="1"		## Enable zpool history gathering
_IOST="1"		## Enable iostat gathering
_HDDISCO="1"	## Enable hddisco gathering
_DEVFSA="1"		## Enable devfsadm data gathering
iostat_repeat="60"
iostat_range="1"
fmd_num_days="14"
VER=1.0.6

func_cleanup ()
{
	/usr/bin/rm -f ${FILES_ARR[@]}
	# /usr/bin/rm -f /tmp/general-diag*.txt.*
	return $?
}

func_add_to_f_array ()
{
	local value=$1
	FILES_ARR+=(${value})
}

func_get_zfs_history ()
{
## Function 
## Collect zpool history information for each pool imported on the system
##
local NUM_LINES=100		## Number of lines to select from end of history
local OUTPUT=${PRE}-zpool-hist.txt
	for iter in ${ZPOOL_ARR[@]}; do
		printf "%s\n" "###### Begin History Pool: ${iter} ######" >> ${OUTPUT}
		${zp_cmd} history -il ${iter} \
		| ${tail_cmd} -${NUM_LINES} >> ${OUTPUT}
		printf "%s\n" "###### End History Pool: ${iter} ######" >> ${OUTPUT}
		done
}

################################################################################
### Basic sanity checks ########################################################
################################################################################
if [[ ! $(${un} -v) =~ NexentaOS ]]; then
	printf "%s\n" "[CRITICAL] System is not a NexentaStor Appliance."
	exit 1
elif [ ! -x "${nmc_cmd}" ]; then
	printf "%s\n" "[CRITICAL] NMC is not found." \
	"This script may not be apporpriate for this system."
	exit 1
fi

################################################################################
### Begin Gathering of logs here ###############################################
################################################################################
printf "%s\n" "Nexenta Systems, inc." "Running [$0] : Log Collector version ${VER}"

################################################################################
### All information collected from NMC #########################################
################################################################################

printf "%s\n" "[START] Collecting Diagnostics and System Logs via NMC."

## generates ${WORK_DIR}/general-diag-27340.txt.gz
${nmc_cmd} -c "setup diagnostics run -y" && ${mv_cmd} ${WORK_DIR}/general-diag*.txt.gz ${PRE}-diags.txt.gz
${nmc_cmd} -c "show appliance syslog dmesg" > ${PRE}-dmesg.txt
${nmc_cmd} -c "show all" > ${PRE}-config.txt
${nmc_cmd} -c  "show faults -v" > ${PRE}-faults-verbose.txt

for iter in -diags.txt.gz \
			-dmesg.txt \
			-config.txt \
			-faults-verbose.txt
    do
		func_add_to_f_array ${PRE}${iter}
	done

printf "%s\n" "[STOP] Collecting Diagnostics and System Logs via NMC."

################################################################################
### All information collected from FMD #########################################
################################################################################
if [[ ${_FMA} -eq 1 ]]; then
	printf "%s\n" "[START] Collecting Fault Management Data."
	fma_args=( ags agr agv )
	for args in ${fma_args[@]}; do 
		${fma_faulty_cmd} -${args} >> ${PRE}-fmadm-diag.txt
	done
	printf "%s\n" "[STOP] Collecting Fault Management Data."
	func_add_to_f_array ${PRE}-fmadm-diag.txt
fi

if [[ ${_FMD} -eq 1 ]]; then
	printf "%s\n" "[START] Collecting Fault Management RAW Diagnostic Data."
	${fmdump_cmd} -eV -t${fmd_num_days}day >> ${PRE}-fmdump-eV.txt
	printf "%s\n" "[STOP] Collecting Fault Management RAW Diagnostic Data."
	func_add_to_f_array ${PRE}-fmdump-eV.txt
fi

################################################################################
### All information collected from kstat #######################################
################################################################################
if [[ ${_KST} -eq 1 ]]; then
	printf "%s\n" "[START] Collecting Kernel Statistics."
	## Add more kstat items here, this is just a start
	printf "%s\n" "###### CPU Related: ######" >> ${PRE}-kstat-var.txt
	${kstat_cmd} -p cpu_info:::current_cstate >> ${PRE}-kstat-var.txt
	${kstat_cmd} -p cpu_info:::supported_max_cstates >> ${PRE}-kstat-var.txt
	printf "%s\n" "###### ARC Related: ######" >> ${PRE}-kstat-var.txt
	${kstat_cmd} -p zfs:*:arc* >> ${PRE}-kstat-var.txt

	for iter in H S T; do
		${kstat_cmd} -p sderr:*:sd*,err:${iter}*Err* >> ${PRE}-kstat-sderr.txt
	done
	printf "%s\n" "[STOP] Collecting Kernel Statistics."
	func_add_to_f_array ${PRE}-kstat-var.txt
	func_add_to_f_array ${PRE}-kstat-sderr.txt
fi

################################################################################
### All information collected about Disks ######################################
################################################################################
printf "%s\n" "[START] Collecting Disk-related Statistics."
## Grab some iostats, as long as we enabled iostat via ${_IOST} earlier
if [ ${_IOST} -eq 1 ]; then
	${iostat_cmd} -YxnzTd ${iostat_range} ${iostat_repeat} >> ${PRE}-iostat-YxnzTd.txt
	${iostat_cmd} -En >> ${PRE}-iostat-En.txt
	${iostat_cmd} -en >> ${PRE}-iostat-en.txt
	func_add_to_f_array ${PRE}-iostat-YxnzTd.txt
	func_add_to_f_array ${PRE}-iostat-En.txt
	func_add_to_f_array ${PRE}-iostat-en.txt
fi

if [ ${_HDDISCO} -eq 1 ]; then
	${hdd_cmd} >> ${PRE}-hddisco.txt
	func_add_to_f_array ${PRE}-hddisco.txt
fi

## Output from 'cfgadm -al' is meaningful when diagnosing disk issues
if [ ${_CFGADM} -eq 1 ]; then
	${cfgadm_cmd} -al >> ${PRE}-cfgadm-al.txt
	func_add_to_f_array ${PRE}-cfgadm-al.txt
fi

if [ ${_DEVFSA} -eq 1 ]; then
	${devfsadm_cmd} -Csv >> ${PRE}-devfsadm-Csv.txt
	${devfsadm_cmd} -c disk -sv >> ${PRE}-devfsadm-c-disk-sv.txt
	func_add_to_f_array ${PRE}-devfsadm-Csv.txt
	func_add_to_f_array ${PRE}-devfsadm-c-disk-sv.txt
fi

printf "%s\n" "[STOP] Collecting Disk-related Statistics."

###############################################################################s#
### Stop All gathering activities here #########################################
################################################################################

cd ${WORK_DIR}
tar czvf ${GZ_OUT_F} $(echo ${FILES_ARR[@]}) &>/dev/null

if [ $? -eq 0 ]; then
	printf "%s\n" "Successfully generated archive." \
	"[Archive] $(ls -l ${GZ_OUT_F})" \
	"Please, supply this file with your reponse to the case. Thank you!"
	func_cleanup
	exit 0
else
	printf "%s\n" "Failed to generate archive, please try again."
	func_cleanup
	exit 1
fi
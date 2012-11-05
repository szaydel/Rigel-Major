#!/usr/bin/bash
#
# Copyright (c) 2012, RackTop Systems. All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies,  either expressed or implied, of the FreeBSD Project.

###############################################################################
#### DESCRIPTION ##############################################################
###############################################################################
##
## This is a bootstrap script intended to startup a clean SmartOS/BrickstorOS
## system customized with parameters required to begin using the system and
## enable its administration and management.
##
###############################################################################

debug=1
inzone=''
local_zone_name="rt_brickstor_admin_zone"
racktop_adm=rtadmin
racktop_grp=rtadmin
racktop_home=/racktop/home
ssh_pub_key='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvZFBaWT5yOTgLD+zu37fyVFPeE+Us6BmNT6zEHrJUPIyDNir2I9zaobqqedtNPORNCNpR9In/KsoPYWpuL0ph1ukOmBKKfuEP14W67c0uIbMTRjhZQHiT2tiDP1YaBkFUNdd+JSAMV30h4ZVrOaGg/fKIth6HZpP0QqOHRLi+dI/dFI6xwcZzcwPuZrIrHtopuhtoh9C3q/JudHO8HB4W4H/u4Hs8uxEjTp00u5d4uW7Io/ZDAavGGZ1bui2pPrp+bshR0cn+t7aFg73qmtdtqtH0nhBtUXEm6F/8HnZOUJJsOO4faTQbQ9hBjbwRzUD39M0sBYMp+zS343Z4x5qfw== Common ssh internal.dom key'

RT_PYTHON_REQS="APScheduler==2.0.3
Fabric==1.4.3
Logbook==0.4
Pygments==1.5
cement==2.0.2
clom==0.7.4
distribute==0.6.28
envoy==0.0.2
eventlet==0.9.17
fablib==0.1.0
fabtools==0.7.0
greenlet==0.4.0
httpie==0.3.0
pycrypto==2.6
pytz==2012g
requests==0.14.1
sh==1.04
ssh==1.7.14
tablib==0.9.11
wsgiref==0.1.2"

## Get list of avilable datasets. For now, we are just using the latest base64
## dataset from Joyent. There is not much info out there about self-building
## datasets, but it is seemingly not all that difficult.
# dsadm avail|grep base64
# 60a3b1fa-0674-11e2-abf5-cb82934a8e24 smartos 2012-09-25 sdc:sdc:base64:1.8.1   
# e8c41d40-f161-11e1-b839-a3631c115653 smartos 2012-08-28 sdc:sdc:base64:1.7.2   
# 8da4bc54-d77f-11e1-8f6f-cfe8e7177a23 smartos 2012-07-27 sdc:sdc:base64:1.7.1   
# d0eebb8e-c9cb-11e1-8762-2f01c4acd80d smartos 2012-07-10 sdc:sdc:base64:1.7.0

default_uuid=60a3b1fa-0674-11e2-abf5-cb82934a8e24

function _check_return_code()
{
	## Function's only argument is return code from previous command.
	local rc=$1
	if [[ ${rc} -ne 0 ]]; then 
		printf "[DEBUG] %s\n" "Received status code other than 0."
		return 1 
	else
		printf "[DEBUG] %s\n" "Received status code 0."
		return 0
	fi
}

function _populate_ssh_authorized_users()

{
	local key_file=$1
	local ssh_dir=${key_file//\/auth*}
	local ssh_key=$2

	## If the .ssh directory is not there, we create it.
	mkdir -p ${ssh_dir}
	touch ${key_file}; _check_return_code $? || return 1

	chmod 700 ${ssh_dir}; _check_return_code $? || return 1
	chmod 400 ${key_file}; _check_return_code $? || return 1

	printf "%s\n" "${ssh_key}" > ${key_file}; _check_return_code $? || return 1

	return 0
}

function _create_admin_zone()
{
	vmadm create <<EOF
{
  "alias": "rt_brickstor_admin_zone",
  "hostname": "project_lhc.local",
  "brand": "joyent",
  "dataset_uuid": "${default_uuid}",
  "autoboot": true,
  "vcpus": 1,
  "ram": 256,
  "resolvers": [
    "8.8.8.8",
    "8.8.4.4"
  ],
  "nics": [
    {
      "nic_tag": "admin",
      "ip": "10.255.0.100",
      "netmask": "255.255.0.0",
      "gateway": "10.255.1.30"
    },
    {
      "nic_tag": "external",
      "ip": "dhcp",
      "gateway": "10.0.3.2",
      "primary": "true"
    }
  ]
}
EOF

}

function _configure_global_zone () 
{
	local group_file=/etc/group
	local passwd_file=/etc/passwd
	local shadow_file=/usbkey/shadow
	local prof_file=/etc/security/prof_attr
	local user_file=/etc/user_attr
	local exec_file=/etc/security/exec_attr
	local ssh_keys=/.ssh/authorized_keys

	## First we make sure that root can ssh in. Need to setup authorized_users.
	_populate_ssh_authorized_users /root/.ssh/authorized_keys "${ssh_pub_key}"; 
	_check_return_code $? || \
		(printf "[CRIT] Failed assignments of security settings for %s. Cannot continue.\n" "root"
		return 1)

	## Create user account for RackTop Administrator using ${racktop_adm}
	## if user account does not already exist on system. If we return a hit here
	## we already have the admin account created, and should skip this step.

	## >>> Checking/Updating /etc/security/prof_attr here <<<
	## If we return a hit here, we already have entries in /etc/security/prof_attr, 
	## and as such we skip making this change.
	local x=$(/usr/xpg4/bin/awk -v search="RT-Primary-Administrator" '$0 ~ search' ${prof_file})
	if [[ -z ${x} ]]; then	
		printf "RT-Primary-Administrator:::Can perform all administrative tasks:auths=solaris.*,solaris.grant;help=RtPriAdmin.html\n" >> ${prof_file}
		
		_check_return_code $? || \
		(printf "[CRIT] Failed assignments of security settings for %s. Cannot continue.\n" ${racktop_adm}
		return 1)
	fi

	## If we return a hit here, we already have entries in /etc/user_attr, 
	## and as such we skip making this change.
	local x=$(/usr/xpg4/bin/awk -v search="RT-Primary-Administrator" '$0 ~ search' ${user_file})
	if [[ -z ${x} ]]; then
		printf "%s::::profiles=RT-Primary-Administrator;type=normal;auths=solaris.admin.*,solaris.file.*,solaris.device.*,solaris.network.*,solaris.system.*,solaris.smf.*,solaris.zone.*\n" ${racktop_adm} >> ${user_file}

		_check_return_code $? || \
		(printf "[CRIT] Failed assignments of security settings for %s. Cannot continue.\n" ${racktop_adm}
		return 1)
	fi

	## If we return a hit here, we already have entries in /etc/security/exec_attr, 
	## and as such we skip making this change.
	local x=$(/usr/xpg4/bin/awk -v search="RT-Primary-Administrator" '$0 ~ search' ${exec_file})
	if [[ -z ${x} ]]; then
		printf "RT-Primary-Administrator:solaris:cmd:::*:uid=0;gid=0\n" >> ${exec_file}

		_check_return_code $? || \
		(printf "[CRIT] Failed assignments of security settings for %s. Cannot continue.\n" ${racktop_adm}
		return 1)
	fi

	## Create group for RackTop Administrator if not already present.
	## It is not likely to already exist, but we may use this code in
	## different situations, and so just want this code to be sane.
	[[ ! $(grep rtadmin /etc/group) ]] && echo "rtadmin::1112:" >> ${group_file}

	local x=$(/usr/xpg4/bin/awk -v search="${racktop_adm}" '$0 ~ search' /etc/passwd)
	if [[ -z ${x} ]]; then
		printf "${racktop_adm}:x:1112:1112:RackTop GZ Administrator:${racktop_home}/${racktop_adm}:/bin/bash\n" >> ${passwd_file}
		_check_return_code $? || \
		(printf "[CRIT] Failed assignments of security settings for %s. Cannot continue.\n" ${racktop_adm}
		return 1)
	fi

	## Write a No-password to /usbkey/shadow, this only hapens once.
	[[ ! $(grep ${racktop_adm} ${shadow_file}) ]] && printf "%s:*NP*:::::::\n" "${racktop_adm}" >> ${shadow_file}

	if [[ ! $(mount | grep ${racktop_home}/${racktop_adm}) ]]; then
		local ZFS_CMD=/usr/sbin/zfs
		${ZFS_CMD} create -p zones${racktop_home}/${racktop_adm}
		_check_return_code $? || return 1
		${ZFS_CMD} set mountpoint=${racktop_home} zones${racktop_home}
		_check_return_code $? || return 1
		${ZFS_CMD} set mountpoint=${racktop_home}/${racktop_adm} zones${racktop_home}/${racktop_adm}
		_check_return_code $? || return 1

		chown -R ${racktop_adm}:${racktop_grp} ${racktop_home}/${racktop_adm}
		_check_return_code $? || return 1
	fi

	## Check for presence of ssh configuration and add key if needed.
	if [[ ! -f ${racktop_home}/${racktop_adm}/.ssh/authorized_keys ]]; then

		_populate_ssh_authorized_users ${racktop_home}/${racktop_adm}/.ssh/authorized_keys "${ssh_pub_key}"
		_check_return_code $? || return 1

		## Make sure that .ssh and its contents are owned by $racktop_adm.
		chown -R ${racktop_adm}:${racktop_grp} ${racktop_home}/${racktop_adm}/.ssh
		_check_return_code $? || return 1
	else
		chown -R ${racktop_adm}:${racktop_grp} ${racktop_home}/${racktop_adm}/.ssh
	fi

	return 0
}

function _get_dataset()
{
	dsadm import ${default_uuid}

}

function _which_zone()
## Determine which zone we are currently in. If we are inside the global
## zone, we can continue building, otherwise we need to switch to
## configuring the local zone.
{
	if [[ $(zonename) == 'global' ]]; then
		## We are running inside the global zone
		## should be able to continue with config.
		inzone='global'
	else
		inzone='local'
	fi
	printf "[DEBUG] %s\n" "Variable inzone set to ${inzone}."
}

function _admin_zone_not_exist()
## Test for whether local administration zone is already present, if so, we
## need to skip this part and instead run this script in the zone, to complete
## necessary steps to build the smart machine for RackTop admin.
{
	local x=$(vmadm lookup alias=${local_zone_name} 2>/dev/null)

	## If lookup fails and we have an emtpy string, the zone does not
	## exist yet, and we should go ahead and create it. In this case
	## we will return 0 from this function. Otherwise, we return 1.
	if [[ -z ${x} ]]; then
		[[ ${debug} -ge 1 ]] && printf "[INFO] %s\n" "Zone \<${local_zone_name}\> does not exist."
		return 0
	else
		[[ ${debug} -ge 1 ]] && printf "[INFO] %s\n" "Zone \<${local_zone_name}\> already exists."
		return 1
	fi
}

function _base_ds_already_exist()
{
	local uuid=$1
	local ds=( $(dsadm list|awk '{if (NR!=1) {print $1}}') )

	for item in ${ds[@]}; do

		if [[ ${item} == ${uuid} ]]; then
			printf "[INFO] %s\n" "Dataset ${dataset_uuid} already exists. Will not download again."
			return 0
		fi
	done
	return 1
}

function _configure_admin_zone()
{
	## We are going to install a number of things with pkgin.
	## Function will also deploy necessary Python tools and libraries.
	## Python 2.7.x is already on a normal base64 smart machine, 
	## so we are in good shape.
	local CURL_CMD=/usr/bin/curl
	local PKGIN_CMD=/opt/local/bin/pkgin
	local PIP_CMD=/opt/local/bin/pip

	[[ ! -d /racktop ]] && (mkdir -p /racktop && cd /racktop && ln -n -s ../opt/local)
	_check_return_code $? || \
	(printf "[CRIT] %s\n" "Failed with creation of requried directories or symlinks. Cannot continue."
		return 1)

	[[ ! -h /racktop/local ]] && ( cd /racktop && ln -n -s ../opt/local)
	_check_return_code $? || \
	(printf "[CRIT] %s\n" "Failed with creation of requried directories or symlinks. Cannot continue."
		return 1)

	## Modify path, ever so slightly.
	printf "%s\n" "export PATH=/racktop/local/bin:$PATH" >> ~/.bashrc

	if [[ ! -x "${CURL_CMD}" ]]; then
		printf "[CRIT] Unable to locate %s, cannot continue. Please, make sure %s is installed.\n" "${CURL_CMD}"
		return 1
	fi

	if [[ ! -x "${PKGIN_CMD}" ]]; then
		printf "[CRIT] Unable to locate %s, cannot continue. Please, make sure %s is installed.\n" "${PKGIN_CMD}"
		return 1
	fi

	## Install necessary packages inside the zone with pkgin.
	${PKGIN_CMD} -y update

	${PKGIN_CMD} -y in \
	gcc47-runtime-4.7.0nb2 \ 
	gcc47-4.7.0nb2 bison-2.5.1 \
	py27-setuptools-0.6c11nb1 \
	py27-sqlite3-0nb3 \
	sqlite3-3.7.13

	## Install distribute in order to install pip and use pip to deploy other
	${CURL_CMD} http://python-distribute.org/distribute_setup.py | python

	_check_return_code $? || \
	(printf "[WARN] %s\n" "Installation of Python Distribute tools may have been unsuccessful."
	return 1)

	${CURL_CMD} --insecure https://raw.github.com/pypa/pip/master/contrib/get-pip.py | python

	_check_return_code $? || \
	(printf "[WARN] %s\n" "Installation of Python PIP may have been unsuccessful."
	return 1)

	${PIP_CMD} install ${RT_PYTHON_REQS}

	return 0
}

_which_zone

case ${inzone} in
	"global" )
		## While in the Global Zone, we need to make sure that some basic
		## requirements are addressed, such as administration user who is
		## not root exists, as that will be the account with which we do
		## various administrative things. SSH has to be configured to all
		## for passwordless login from Admin zone, permissions, auths, etc.
		printf "[INFO] %s\n" "Running inside the Global Zone. Please be patient, setting-up environment."

		_configure_global_zone; _check_return_code $? || \
			printf "[WARN] %s\n" "Something unexpected occurred, and tasks stopped prematurely. Cannot continue."
			exit 1
		## If we are in the Global Zone we need to determine whether we already
		## have a smart machine built for administration of host. If we do,
		## we should stop here and move on to the host.
		_admin_zone_not_exist; _check_return_code $? || \
			printf "[WARN] %s\n" "Administration zone appears to already exist. Cannot continue."
			exit 1
			## Get list of all available datasets and make import one we need if not
			## already imported. If one of the elements in the array matches $default_uuid,
			## we skip dataset related tasks and create the zone right away.

			## Test for whether local administration zone is already present, if so, we
			## need to skip this part and instead run this script in the zone, to complete
			## necessary steps to build the smart machine for RackTop admin.

			_base_ds_already_exist ${default_uuid}; ret_code=$?
			if [[ ${ret_code} -eq 0 ]]; then
				printf "[INFO] %s\n" "Administration zone creation under way. Please be patient."
				_create_admin_zone
			else
				_get_dataset
			fi
		;;

	"local" )
		
		printf "[INFO] %s\n" "Running inside the Local Zone. Please be patient, setting-up environment."
		_configure_admin_zone; ret_code=$?
		if [[ ${ret_code} -ne 0 ]]; then
			printf "[ERROR] %s\n" "Due to critical errors script is terminating early."
			exit 1
		fi

		;;
esac


## If we are still in this script


## If in local zone, we need to also do the following things:

# 1) Create directory /racktop
# 2) Create symlink under /racktop to ../opt/local
# 3) Modify root\'s bashrc with path starting from /racktop/opt/local/bin



## Script will deploy necessary Python tools and libraries.
## We cannot use this until the Python package built for RackTop Systems
## is installed, because this will require version 2.7.x of Python on
## the system.

# RT_ROOT_DIR=/racktop
# RT_PYTHON_REQS=rt-pip-stable.reqs
# BUILD_REQS=${RT_ROOT_DIR}/build_reqs/${RT_PYTHON_REQS}
# CURL_CMD=/usr/bin/curl

# if [[ ! -x "${CURL_CMD}" ]]; then
# 	printf "[CRIT] Unable to locate %s, cannot continue. Please, make sure %s is installed.\n" "${CURL_CMD}"
# 	exit 1
# fi

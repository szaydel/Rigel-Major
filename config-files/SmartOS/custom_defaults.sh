#!/bin/bash
# Simple Ad Hoc SmartOS Setup Service

set -o xtrace

. /lib/svc/share/smf_include.sh

cd /
PATH=/usr/sbin:/usr/bin:/opt/custom/bin:/opt/custom/sbin; export PATH

ssh_src_dir=/opt/custom/.ssh
src_dir=/opt/custom
rc_src_dir=${src_dir}/startup/rcfiles
root_home_dir=/root
persist_etc_dir=/opt/local/etc
ntp_config=${persist_etc_dir}/inet/ntp.conf
default_configs=( ".bash_history" ".bashrc" ".npmrc" )

case "$1" in
'start')
    #### Insert code to execute on startup here.
    #hostname "smartos01" && hostname > /etc/nodename

	for file in ${default_configs[@]}; do
		if [[ -f ${rc_src_dir}/${file} ]]; then

			## Rename the original file in root's home directory, if exists.
			if [[ -f ${root_home_dir}/${file} ]]; then
				mv ${root_home_dir}/${file} ${root_home_dir}/${file}.renamed
			fi
			## Symlink to files in the persistent rc directory from root's home.
			ln -s ${rc_src_dir}/${file} ${root_home_dir}/${file}
		fi
	done

	#ln -s ${rc_src_dir}/vanilla-svr.bash_aliases /root/.bash_aliases
	#ln -s ${rc_src_dir}/vanilla-svr.bashrc /root/.bashrc
	#ln -s ${rc_src_dir}/smartosrc /root/smartosrc
	#ln -s ${rc_src_dir}/.npmrc /root/.npmrc
	ln -s ${ssh_src_dir} ${root_home_dir}/.ssh


	## Modify NTP to point to local router
	svcadm enable svc:/network/ntp:default
	mv /etc/inet/ntp.conf{,.renamed}
	ln -s ${ntp_config} /etc/inet/ntp.conf
	svcadm refresh svc:/network/ntp:default

    ;;

'stop')
    ### Insert code to execute on shutdown here.
    ;;

*)
    echo "Usage: $0 { start | stop }"
    exit $SMF_EXIT_ERR_FATAL
    ;;
esac
exit $SMF_EXIT_OK


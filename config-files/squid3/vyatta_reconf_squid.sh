#!/bin/bash

squid_dir=squid3
confs=etc
squid_cfg=/${confs}/${squid_dir}/squid.conf

set -x

## Replace /etc/squid3/squid.conf with a symlink to /opt/custom/etc/squid3

[[ -f ${squid_cfg} ]] && ( mv ${squid_cfg} ${squid_cfg}.moved \
	&& ln -s /opt/custom/etc/squid3/squid.conf ${squid_cfg} )

## Reload squid config

service squid3 reload; retcode=$?

if [[ ${retcode} -eq 0 ]]; then
	logger -p daemon.notice -t post_vyatta_boot "Replaced Vyatta default squid3 configuration with custom conf file ${squid_cfg}"
fi

exit ${retcode}
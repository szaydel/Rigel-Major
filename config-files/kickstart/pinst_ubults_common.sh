#!/bin/bash

## Create rtconf account to make deployment via ansible easier.
[[ $(groups rtconf >/dev/null 2>/dev/null) ]] || groupadd -g 411 rtconf
[[ $(id rtconf >/dev/null 2>/dev/null) ]] || adduser --system --home /home/rtconf --shell /bin/bash --uid 411 --gid 411 --disabled-password rtconf

rtconf_ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCeQKLsdQCsa16FVjbE8aJ+yworMl9SGa/AvGxe8q/6O1/w35xA+SBpca67UW01fum64Di5tqeyPEZZCH5UtQJSYVFVVKT9rM37P0HedOBD2H8Lkum6cATQHwHFiDqSd+qwZYQtCbIZc3p36Dtr3bB9vsQaeQwU9yPUiX3QV9wk7b9+KAbvJzLHl4CCK0yexPT1A+f852WFZCJBLvvLwY2NgZLGxYC7kvFhSSwjaejMVjteNqI9bbUh1Wkwge+S9SALW7HU0Uj8ynImpIV4z1jT6Cas9vyNkYGvKcZ6CzjYFwV6cipbj2sYsQcaPZCZLrLvyHncF/WT6AqkZ1CY2sJ RackTop@Administration-Public-Key"
ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9lQKwWU+VQrZZ+dWPddDraLCDDxnkprEEKuvcEYtqWsdG1yYuVuALt+DoPY2R2ZgJOx+ld8jQXsqpYlWTstsqs+57GCruThilMD+1dTM4zO28TrG2x5Q5SkhS/S/JD4ljb/Bfx4VUhOLrqVM3fiR5JKYtZlfJ6/C5HY+pN0Ur5znQWPchE2OxHiMvPzd7HW5U3svUDUpOiSIYPJx63xdWX9KMyYpbSz9UquoxQxMfTZTpBzi9kwGEpBY/mLHKGSvlbrTik/p4uLUQ9kN4veTXjwpyxednfJOZNctEWDKqNdcidVUtf5d1OGJjW8ntvrt1qfwjupq1XsLj02lNE2u1 RackTop@Administration-Public-Key"

pi=/root/post-install.log

dirs=( "/home/labadm" "/root" "/home/rtconf" )

for dir in ${dirs[@]}; do

	[[ ! -d ${dir}/.ssh ]] && mkdir --mode=0700 --parents ${dir}/.ssh;
	printf "%s\n" "Created .ssh directory in ${dir}" >> ${pi}

	if [[ ${dir} == "/home/rtconf" ]]; then
		echo ${rtconf_ssh_key} > "${dir}/.ssh/authorized_keys"
		# chmod 700 ${dir}/.ssh
	else	
		echo ${ssh_key} > "${dir}/.ssh/authorized_keys"
		# chmod 700 ${dir}/.ssh
	fi

	printf "%s\n" "Created .ssh/authorized_keys ${dir}/.ssh" >> ${pi}	

	## If this is labadm or rtconf, we want to make sure that keys
	## are chown'd to 1000 or 411, instead of 0.
	##
	if [[ ${dir} == "/home/labadm" ]]; then
		chown -R 1000:1000 ${dir}/.ssh;

	elif [[ ${dir} == "/home/rtconf" ]]; then
		chown -R 411:411 ${dir}/.ssh;
	fi

	printf "%s\n" "Changed .ssh ownership for ${dir}/.ssh" >> ${pi}

done

echo "%labadm ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-labadm; chmod 400 /etc/sudoers.d/10-labadm;
echo $(TZ='US/Eastern' date +"%c %:z") > /etc/install.timestamp;

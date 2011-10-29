#!/bin/bash
##
##
##
## File Management functions

encryptfile()
{
if [ -z "$1" ]
	then
echo 'Usage: encryptfile filename...';
	else
openssl aes-256-cbc -a -salt -in $1 -out "$1.enc"
fi
}

decryptfile()
{
if [ -z "$1" ]
        then
echo 'Usage: decryptfile filename...';
        else
echo 'Enter filename after decryption...'
read f
openssl aes-256-cbc -a -d -in "$1" -out "$f"
fi
}

## Function to first shred and then remove file(s)
secure-remove()
{
if [ -z $1 ]; then
	printf "%s\nPlease enter at least one filename.\n"
	return 1
	else
		for filename in "$@"
		do
		clear
		printf "%s\nShredding and removing file ${filename} ...\n"
		shred --iterations=7 --remove ${filename}
		[ $? = 0 ] && printf "%s\nFile ${filename} has been securely removed.\n"
		return 0
		done
fi
}

## Function to remove packages installed today
remove-todays-packages()
{
grep "`date "+%Y-%m-%d"`" /var/log/dpkg.log | awk '{print $4}' | xargs sudo apt-get -y remove --purge
}

## Test password generate
# genpass()
# {
# [ -z ${1} ] && printf "%sUsage: Enter length of password to generate... i.e. genpass 10\n" \
# || /usr/bin/openssl rand -base64 300 | cut -c 1-${1}
# }


## SSH related functions
copy-my-key()
{
[ -z ${1} ] && printf "%sUsage: Enter name of remote host... i.e. copy-my-key testbox01\n" \
|| cat ~/.ssh/id_rsa.pub | ssh $(whoami)@${1} "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
}
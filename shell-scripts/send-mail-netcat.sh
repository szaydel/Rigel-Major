#!/bin/bash
## Script used to send plain text emails using netcat utility instead of a real
## mail client

myos=$(uname -o)
full_uname=$(uname -a)
time_stamp=$(date '+%a, %d %b %Y %H:%M:%S %z')
host_n=$(hostname)
get_usr=$(/usr/bin/getent passwd "${UID}")

## Your default mailserver goes here
mail_svr=server03.internal.dom
## Port for your mailserver goes here
port=25

case "${myos}" in
"Solaris")
    printf "%s\n" "#######################[ Running on Solaris ]###################################"
    nc_cmd=/usr/bin/netcat
    top_cmd="/usr/bin/prstat 5 1"
    ;;
"GNU/Linux")
    printf "%s\n" "########################[ Running on Linux ]####################################"
    nc_cmd=/bin/netcat
    top_cmd="/usr/bin/top -d5 -n1"
    ;;
*)
    echo "I am not meant to work with this OS. Sorry."
    exit 1
    ;;
esac

## Combine everything together and pipe the heredoc through netcat
${nc_cmd} ${mail_svr} ${port}<<EOF

HELO ${host_n}
MAIL FROM:<admin@server-vm5.internal.dom>
RCPT TO:<szaydel@gmail.com>
DATA
From: [System Administrator] <admin@server-vm5.internal.dom>
To: <szaydel@gmail.com>
Date: ${time_stamp}
Subject: Test Message from ${host_n}

This is purely a test message sent at ${time_stamp} from ${host_n}.
Proc ID: $$
Proc running as: ${UID}
User Info: ${get_usr}
OS Info: ${full_uname}
.
QUIT
EOF

exit $?

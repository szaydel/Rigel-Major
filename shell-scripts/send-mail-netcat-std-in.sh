#!/bin/bash
## Script used to send plain text emails using netcat utility instead of a real
## mail client

help_menu () {
PROG=$(basename $0)
usage="Usage: \n \
${PROG} [-f path_to_log_file] [-m mailserver] [-r email-address]\n \
\t\t[-h] \tThis usage text.\n \
\t\t[-f filename] \t Select this log file.\n \
\t\t[-m] \tSpecify which mailserver to use as the MTA.\n \
\t\t[-d #] \tTurn on debug information.\n \
\n"
echo -e "${usage}"
}

if [ "$#" -lt "1" ]; then
    help_menu
    exit 0
fi

myos=$(uname -o)
full_uname=$(uname -a)
time_stamp=$(date '+%a, %d %b %Y %H:%M:%S %z')
host_n=$(hostname)
get_usr=$(/usr/bin/getent passwd "${UID}")

## Your default mailserver goes here
mail_svr=server03.internal.dom
## Port for your mailserver goes here
port=25

OPTIND=1

while getopts hd:f:m:r: ARGS

do
  case "${ARGS}" in
  
    d)
    DEBUG=${OPTARG}
    [[ "${DEBUG}" -ge "1" ]] && echo "Debugging at level ${DEBUG} enabled."
    ;; 
  
    f)
    INPUT_FILE=${OPTARG}
    [[ "${DEBUG}" -ge "1" ]] && echo "${INPUT_FILE}"
    ;;
    
    m)
    MAILER=${OPTARG}
    [[ "${DEBUG}" -ge "1" ]] && echo "${MAILER}"
    ;;
    
    r)
    DEST_EMAIL=${OPTARG}
    [[ "${DEBUG}" -ge "1" ]] && echo "${DEST_EMAIL}"
    ;;
    
    h|*)
    help_menu
    exit 0
    ;;  
  esac
done

if [ -z "${MAILER}" ]; then
    printf "%s\n" "[CRITICAL] Cannot Continue, mailer is not Supplied."
    exit 1
elif [ -z "${INPUT_FILE}" ]; then
    printf "%s\n" "[CRITICAL] Cannot Continue, input data is not Supplied."
    exit 1
elif [ -z "${DEST_EMAIL}" ]; then
    printf "%s\n" "[CRITICAL] Cannot Continue, destination is not Supplied."
    exit 1
fi

case "${myos}" in
"Solaris")
    printf "%s\n" "#######################[ Running on Solaris ]###################################"
    nc_cmd=/usr/bin/netcat
    domain=$(cat /etc/defaultdomain)
    #top_cmd="/usr/bin/prstat 5 1"
    ;;
"GNU/Linux")
    printf "%s\n" "########################[ Running on Linux ]####################################"
    nc_cmd=/bin/netcat
    CUT=/usr/bin/cut
    HOST=/usr/bin/host
    SED=/bin/sed
    domain=$(${HOST} ${host_n} | ${CUT} -d" " -f1| ${SED} -re "s/${host_n}.//g")
    echo $domain
    #top_cmd="/usr/bin/top -d5 -n1"
    ;;
*)
    echo "I am not meant to work with this OS. Sorry."
    exit 1
    ;;
esac

FROM_ADDR="admin@${host_n}.${domain}"
## Combine everything together and pipe the heredoc through netcat
${nc_cmd} ${mail_svr} ${port}<<EOF

HELO ${host_n}
MAIL FROM:<${FROM_ADDR}>
RCPT TO:<${DEST_EMAIL}>
DATA
From: [System Administrator] <${FROM_ADDR}>
To: <${DEST_EMAIL}>
Date: ${time_stamp}
Subject: State of ZFS Pools from ${host_n}.${domain}

State of ZFS Pools at ${time_stamp} from ${host_n}.${domain}
Proc ID: $$
Proc running as: ${UID}
User Info: ${get_usr}
OS Info: ${full_uname}
$(cat ${INPUT_FILE})
.
QUIT
EOF

exit $?

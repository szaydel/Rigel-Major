#!/bin/bash
## Script used to bootstrap the system. This is a chain-loading
## script, which will trigger other scripts when called with a
## start or stop method. Reason for this is that not all scripts
## will need to run when stop is being issued on shutdown, etc.

set -o xtrace

. /lib/svc/share/smf_include.sh

cd /
PATH=/usr/sbin:/usr/bin:/opt/custom/bin:/opt/custom/sbin; export PATH

case "$1" in
'start')
    #### Insert code to execute on startup here.
    /opt/custom/share/svc/bootstrap_gz-01.sh
    hostname "storage-01" && hostname > /etc/nodename
    ;;

'stop')
    ### Insert code to execute on shutdown here.
    true
    ;;

*)
    echo "Usage: $0 { start | stop }"
    exit $SMF_EXIT_ERR_FATAL
    ;;
esac
exit $SMF_EXIT_OK
#!/usr/bin/bash

INTERFACE=$1
ADDRESS=$2
GATEWAY=$3

V6AUTO=1

errorCheck()
{
        if [ $? -ne 0 ]; then
                echo "ERROR: $@"
                exit 69
        fi
}

# Handle Args
if [ $# -ne 3 ]; then
        echo "ERROR: Invalid arguments"
        echo "Usage:\n\t$0: INTERFACE ADDRESS/CIDR-MASK GATEWAY/DEFAULTROUTER"
        exit 1
fi

ipadm create-if $INTERFACE
errorCheck "Unable to create-if $INTERFACE"

ipadm create-addr -T static -a local=${ADDRESS} ${INTERFACE}/v4static
errorCheck "Unable to set static v4 on $INTERFACE"

if [ $V6AUTO -ne 0 ]; then
        ipadm create-addr -T addrconf ${INTERFACE}/v6addr
        errorCheck "Unable to set v6 autoconf on $INTERFACE"
fi

if [ $GATEWAY != "" ]; then
        route add default $GATEWAY
        errorCheck "Unable to set default router to $GATEWAY"
else
        echo "!--> Not setting gateway as none was set ..."
fi

echo "--> Finished setting $ADDRESS on $INTERFACE with $GATEWAY default route ..."
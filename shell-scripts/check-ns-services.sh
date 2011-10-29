#!/bin/bash

## Define our NS services and commands to use
ns_svcs=( $(svcs -a | egrep 'dbus|nm[csv]'| awk '{print $3}'|xargs) )
svcs_r="/usr/sbin/svcadm restart"
svcs_c="/usr/sbin/svcadm clear"
svc_info="/usr/bin/svcs -v"
delay="4"
delay_l="10"

printf "%s\n" "----------------------[ Restarting NexentaStor Services ]-----------------------"

## First we restart each service
for svc in "${ns_svcs[@]}"; do
    ${svcs_r} "${svc}"
done

sleep "${delay}"

## Now we check and clear any service that change to maintenance
for svc in $(svcs -a| egrep 'dbus|nm[csv]'|grep 'maint'| awk '{print $3}'|xargs); do
    ${svcs_c} "${svc}"
done

count=1
while [ "${count}" -lt 4 ]; do
    printf "%s\n" "-------------------- Please wait, services are restarting ["${count}"] ------------------"
    sleep "${delay_l}"
    count=$(( count+1 ))
done

## Now we check status of services
for svc in "${ns_svcs[@]}"; do
    ${svc_info} "${svc}"
done


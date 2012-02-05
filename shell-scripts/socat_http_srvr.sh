#!/bin/bash
#set -x
lsof_cmd=/usr/bin/lsof
file_cmd=/usr/bin/file
## If script is started with a base path as arg1,
## we export that variable and reference it every
## time the script is called recursively
if [[ ! -z $1 ]]; then
    export tmp_socat_basedir=$1
fi

## We set our base to exported variable and use it
## later as part of the filepath
base=$tmp_socat_basedir
_script=$0

## If our mini webserver is already running, we are
## ready to handle requests
if [[ $("${lsof_cmd}" -i TCP:8084) ]]; then
read request

while /bin/true; do
  read header
  [ "$header" == $'\r' ] && break;
done

url="${request#GET }"
url="${url% HTTP/*}"
filename="$base$url"

if [ -f "${filename}" ]; then
    if [[ ! $("${file_cmd}" "${filename}"|cut -d' ' -f1|egrep 'HTML|ASCII') ]]; then 
        ## file is binary, and we want to present as is, no headers
        cat "${filename}"
    else
        echo -e "HTTP/1.1 200 OK\r"
        echo -e "Content-Type: `/usr/bin/file -bi \"$filename\"`\r"
        echo -e "\r"
        cat "${filename}"
        echo -e "\r"
    fi
else
  echo -e "HTTP/1.1 404 Not Found\r"
  echo -e "Content-Type: text/html\r"
  echo -e "\r"
  echo -e "404 Not Found\r"
  echo -e "Not Found
           The requested resource was not found\r"
  echo -e "\r"
fi
exit 0
fi

if [[ -z "$PS1" ]]; then
    if [[ -z "$1" ]]; then
        printf "%s\n" "Please, enter path for base URL as first argument."
        exit 1
    else
        if [[ $(lsof -i TCP:8084)  ]]; then
            printf "%s\n" "Webserver is already running..."
        else
            socat TCP4-LISTEN:8084,fork EXEC:${_script} &
        fi
    fi
fi


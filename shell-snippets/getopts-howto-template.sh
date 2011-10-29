#!/bin/bash
### Testing getopts command

menu () {
Usage="Usage: \n \
\tjkl [-lbmcdxh] [-f filename]\n \
\t\t[-h] \tThis usage text.\n \
\t\t[-f filename] \t cat the specified file. \n \
\t\t[-l] \tGo to application log directory with ls. \n \
\t\t[-b] \tGo to application bin directory. \n \
\t\t[-c] \tGo to application config directory.\n \
\t\t[-m] \tGo to application log directory and more log file.\n \
\t\t[-d] \tTurn on debug information.\n \
\t\t[-x] \tTurn off debug information.\n"

BINDIR=/bin
LOGDIR=/var/log
APPLOG=""

UNAME=$(uname -n)

DATE=`date '+%y%m'`
MYAPP_ID=""

  if [ "$#" -lt 1 ]
  then
      RET_CODE=5
	  echo -e $Usage
	  echo "${RET_CODE}"
  fi

  OPTIND=1
  while getopts lf:bmcdxh ARGS
  do
    case $ARGS in
      l) if [ -d $LOGDIR ] ; then
           cd $LOGDIR
           /bin/ls
         fi
      ;;
      f) FILE=$OPTARG
         if [ -f $FILE ]
         then
           echo cat $FILE
         else
           printf "%s\n" "$FILE not found. Please try again."
           RET_CODE=1
           return "${RET_CODE}"
         fi
      ;;
      b) if [ -d $BINDIR ] ; then
           cd $BINDIR
         fi
      ;;
      m) if [ -d $LOGDIR ] ; then
           cd $LOGDIR
           /bin/more $APPLOG
         fi
      ;;
      c) if [ -d $CFGDIR ] ; then
           cd $CFGDIR
         fi
      ;;
      d) set -x
      ;;
      x) set +x
      ;;
      h) echo -e $Usage
      ;;
      *) echo -e $Usage
         #return
      ;;
     esac
  done
}

CMDLNE_ARGS=$*

echo Number of arguments is $#
menu "${CMDLNE_ARGS}"

printf "%s\n" "Return Code is: ${RET_CODE}"
exit "${RET_CODE}"

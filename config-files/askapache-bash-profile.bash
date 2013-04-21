#!/bin/bash 
#
#  The recommeded way to keep updated is to save this file and source it from your .bash_profile or any script, like:
# 
#      #!/bin/bash
#      dos2unix -dv ~/sites/askapache.com/static/askapache-bash-profile.txt
#      [[ -r ~/sites/askapache.com/static/askapache-bash-profile.txt ]] && . ~/sites/askapache.com/static/askapache-bash-profile.txt
# curl -O http://static.askapache.com/askapache-bash-profile.txt && source askapache-bash-profile.txt
#   or
# curl -o ~/.bash_profile http://static.askapache.com/askapache-bash-profile.txt && bash -l
#
# To run automatically at login: In your ~/.bash_profile or similar login script do 
# [[ -f path-to-askapache-bash-profile.txt ]] && source path-to-askapache-bash-profile.txt
#
# To update to the newest version, by overwriting your current .bash_profile and executing a new environment, run
#   aaup
#
#
# Copyright (C) 2009 www.AskApache.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
############################################################################################################################################################


# http://www.linuxfromscratch.org/lfs/view/6.4/chapter06/chapter06.html










##################################################################################################################################################################################
# Advanced Shell (set)tings, (u)ser(limit)s, and (sh)ell(opt)ions
##################################################################################################################################################################################
[[ ! -z "${BASH_ARGC}${BASH_ARGV}" ]] && ISINCLUDED=yes || ISINCLUDED=no
[[ -z "$PS3" ]] && [[ "$ISINCLUDED" == "no" ]] && return # dont do anything for non-interactive shells
[[ $- != *v* && $- != *x* ]] && set +C +f +H +v +x +n -b -h -i -m -B
ulimit -S -c 0 # Don't want any coredumps
shopt -s histappend histreedit histverify cmdhist extglob dotglob checkwinsize cdable_vars checkhash promptvars
umask 0022

export N6=/dev/null





#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# ahave - Function to check if a program exists in path
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function ahave() 
{ unset -v ahave; command command type $1 &>$N6 && ahave="yes" || return 1; }


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# ahelp - Function to check if help has been called
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function ahelp() 
{ unset -v ahelp; [[ "$#" -gt "0" ]] && [[ "$1" == "-h" || "$1" == "--h" || "$1" == "--help" || "$1" == "-help" || "$1" == "-?" ]] && ahelp="yes"; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# pm - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function pm()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  local I=${1:-3};
  echo -en "$R\n"; #tm 0;
    case ${2:-1} in
     0) echo -en "${CC[6]}-- $X$R";  ;;
     1) echo -e  "${CC[2]}>>> $X$I$R"; ;;
     2) echo -en  "${CC[4]} > $X$I$R"; ;;
     3) echo -e  "${CC[4]} :: $X$I$R"; ;;
    esac;
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_try_for_path - Function that automatically sets up your path
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_try_for_path()
{
  local GP=$HOME/bin:$HOME/sbin
  [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]] && export PATH="/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games"
  
  local P=$PATH:$HOME/libexec
  [[ "$EUID" -eq 0 ]] && P="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11"

  P=${P}:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games
  P=${P}:/bin:/etc:/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/bin/mh:/usr/libexec
  P=${P}:/usr/X11R6/bin:/usr/libexec:/etc/X11:/etc/X11/xinit
  
  [[ "$DREAMHOST" == "yes" ]] && (
    P=${P}:/usr/local/dh/apache/template/bin:/usr/local/dh/apache2/template/bin
    P=${P}:/usr/local/dh/apache2/template/build:/usr/local/dh/apache2/template/sbin
    P=${P}:/usr/local/dh/bin:/usr/local/dh/java/bin:/usr/local/dh/java/jre/bin
	P=${P}:/usr/lib/ruby/gems/1.8/bin:$HOME/.gem/ruby/1.8/bin
  )
  
  P=${P}:/usr/local/php5/bin
  for p in ${P//:/ }; do [[ -d "${p}" && -x "${p}" ]] && GP=${GP}:$p; done;

  export PATH=$( echo -en "${GP//:/\\n}" | sed -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; h; P' | tr "\n" : ).;
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_safe_aliases - Function that sets up safe shell aliases with warnings for common commands, run if root usually
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_safe_aliases()
{
  local MYMVR=$(command type -t mymvmymv)
  [[ "$MYMVR" == "alias" ]] && pm "Turning Safe Aliases Off" && for fa in "chmod" "mkdir" "rm" "cp" "mv" "mymvmymv"; do unalias $fa; done && return;
  pm "Turning Safe Aliases On" 
  alias chmod='command chmod -c'
  alias mkdir='command mkdir -pv'
  alias rm='command rm -v'
  alias cp='command cp -v'
  alias mv='command mv -v'
  alias mymvmymv='echo'
}












#----------------------------
# CUSTOM SETTING VARIABLES
#----------------------------
# uncomment this manually to use root
[[ "$EUID" -eq 0 ]] && echo "If root you should edit this file $0 before letting it run"


AAPN='AskApache Bash Profile Script'
AAPV='6.8'
AAPT='12/07/2009'
AAPS=`echo "$0" | sed -e 's,.*/,,'`


# Be Bourne compatible
(unset GREP_OPTIONS GREP_COLOR) >/dev/null 2>&1 && unset GREP_OPTIONS GREP_COLOR


: ${PATH_SEPARATOR=:}
: ${SHELL=`command type -P bash 2>$N6`}
[[ "$SHELL" == *jail* ]] && export SHELL=`command type -P bash 2>$N6` && exec bash -l
: ${LANG=C} #en_US.UTF-8
: ${LC_ALL=C}
: ${LC_COLLATE=C}
: ${LC_CTYPE=C}
: ${LC_MESSAGES=C}
: ${LC_MONETARY=C}
: ${LC_NUMERIC=C}
: ${LC_TIME=C}

: ${HOME=~}
: ${USER=`whoami 2>$N6 || id -un 2>$N6 || logname 2>$N6`}
: ${GROUPNAME=`id -gn 2>$N6`}
: ${HOSTNAME=`(hostname || uname -n) 2>$N6 | sed 1q`}
: ${TMPDIR=/tmp}


# try and make sure the awesome ll function will work
alias ll='ll';alias ls='ls';unalias ll;unalias ls;(unset ll) >/dev/null 2>&1 && unset ll

# setup DREAMHOST variable for DH-specific stuff
DREAMHOST=no;test -f /usr/local/dh/cgi-system/php.cgi && export DREAMHOST=yes

# first set up path
aa_try_for_path

[[ "$EUID" -eq 0 ]] && aa_safe_aliases;


# setup SSHTTY to send to pty or logfile
ahave tty && SSHTTY=`tty 2>$N6` || SSHTTY=''; export SSHTTY













[[ "$DREAMHOST" == "yes" ]] && (
: ${CFLAGS=-Wall -g -O2}
  # please use tzselect or tzconfig to set yours
  export TZ=${TZ:-America/Indianapolis}
  
  export LDFLAGS="-L${HOME}/lib -L/lib -L/usr/lib -L/usr/lib/libc5-compat -L/lib/libc5-compat -L/usr/i486-linuxlibc1/lib -L/usr/X11R6/lib"
  export LD_LIBRARY_PATH=$HOME/lib
  export CPPFLAGS="-I${HOME}/include -I/usr/i486-linuxlibc1/include"
  [[ -r ${HOME}/etc/ld.so.conf && -r ${HOME}/etc/ld.so.cache ]] && alias ldconfig="ldconfig -v -f ${HOME}/etc/ld.so.conf -C ${HOME}/etc/ld.so.cache"
)


##################################################################################################################################################################################
# Create some config files for the user
##################################################################################################################################################################################
ahave lesspipe && (
  export PAGER=less
  # Less Colors for Man Pages
  export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
  export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
  export LESS_TERMCAP_me=$'\E[0m'           # end mode
  export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
  export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
  export LESS_TERMCAP_ue=$'\E[0m'           # end underline
  export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
  export LESSCHARSET='latin1'
  export LESSOPEN='|gzip -cdfq %s | `type -P lesspipe` %s 2>&-'
  export LESS='-i -N -w  -z-4 -e -M -X -J -s -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
  #alias more='less'
)



#----------------------------
# MAIL, PROGRAMS, EDITOR
#----------------------------
ahave nano && export EDITOR="`type -P nano`" && export VISUAL=$EDITOR
ahave lynx && export BROWSER="`type -P lynx`" && [[ -r $HOME/.lynx/lynx.cfg ]] && export LYNX_CFG=$HOME/.lynx/lynx.cfg;
ahave locate && [[ -r $HOME/var/locatedb ]] && export LOCATE_PATH=$HOME/var/locatedb && export LOCATE_DB=$HOME/var/locatedb







COLORTERM=no; case ${TERM:-dummy} in linux*|con80*|con132*|console|xterm*|vt*|screen*|putty|Eterm|dtterm|ansi|rxvt|gnome*|*color*) COLORTERM=yes; ;; esac; export COLORTERM

export AAC=' --color=auto'

# used by functions below
export RJ=0;








##################################################################################################################################################################################
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
##################################################################################################################################################################################

#---------------
# ls aliases
#---------------
alias llh="ll -h"
alias la="command ls -Al${AAC}"      # show hidden files
alias lx="command ls -lAXB${AAC}"    # sort by extension
alias lk="command ls -lASr${AAC}"    # sort by size
alias lc="command ls -lAcr${AAC}"    # sort by change time
alias lu="command ls -lAur${AAC}"    # sort by access time
alias lr="command ls -lAR${AAC}"     # recursive ls
alias lt="command ls -lAtr${AAC}"    # sort by date
alias lll="stat -c %a\ %N\ %G\ %U \${PWD}/*|sort"



#---------------
# func aliases
#---------------
[[ "$UNAME" != "Linux" ]] && ahave gsed && alias sed='gsed'
alias subash="sudo sh -c 'export HOME=/root; cd /root; exec bash -l'"
ahave updatedb && alias updatedb='( ( updatedb 2>/dev/null ) & )'
alias chmod='command chmod -c'
alias diff='diff -up'
ahave colordiff && alias diff='colordiff -up'
alias env='command env | sort'
alias who='command who -ar -pld'
ahave which || alias which='command type -path'
ahave tree || alias tree='command ls -FR'
ahave tree && alias tree='command tree -Csuflapi'
ahave vim && [[ -r $HOME/.vimrc ]] && alias less='vless'

alias top='top -c'  #command top -d 1 -u $USER
ahave vim && alias vim='command vim --noplugin'
alias du='command du -kh'
alias df='command df -kTh'
alias path='echo -e ${PATH//:/\\n}'

ahave php && alias php='php -d report_memleaks=1 -d report_zend_debug=1 -d log_errors=0 -d ignore_repeated_errors=0 -d ignore_repeated_source=0 -d error_reporting=30719 -d display_startup_errors=1 -d display_errors=1'
alias mann='command man -H'

alias pp='command ps -HAcl -F S -A f'
alias p='command ps -HAcl -F S -A f|uniq -w3'
alias ps2='command ps -H'
alias ps1='command ps -lFA'

alias resetw="echo $'\33[H\33[2J'"
alias df1='command df -iTa'
alias n="${EDITOR}"3
ahave ionice && ahave nice && alias inice='ionice -c3 -n7 nice'
alias dsiz='du -sk * | sort -n --'
alias h='history'
alias j='jobs -l'
alias wtf='watch -n 1 w -hs'
alias cpr='command cp -rpv'
ahave ccze && alias lessc='ccze -A |`type -P less` -R'


















##################################################################################################################################################################################
###
### FUNCTIONS
###
###########################################################################==-==-==-==-==-==-==-==-==-==-==#
#declare -a DNST=( A NS MD MF CNAME SOA MB MG MR NULL WKS PTR HINFO MINFO MX TXT RP AFSDB X25 ISDN RT NSAP NSAP_PTR SIG KEY PX GPOS AAAA LOC SRV AXFR MAILB MAILA NAPTR ANY );
#sed '/./=' ~/.bash_profile | sed '/./N; s/\n/ /'
#sed = ~/.bash_profile |sed 'N; s/^/     /; s/ *\(.\{6,\}\)\n/\1  /'
#find . -type f -iname '*htaccess*' -print0 | xargs -0 grep -sn -i "THE_REQUEST" | sed "s/THE_REQUEST/${SMSO}\0$RMSO}/gI"
#ahave tput && export SMSO=$(tput smso &>$N6);export RMSO=$(tput rmso &>$N6);
#            Color       #define       Value       RGB
#             black     COLOR_BLACK       0     0, 0, 0
#             red       COLOR_RED         1     max,0,0
#             green     COLOR_GREEN       2     0,max,0
#             yellow    COLOR_YELLOW      3     max,max,0
#             blue      COLOR_BLUE        4     0,0,max
#             magenta   COLOR_MAGENTA     5     max,0,max
#             cyan      COLOR_CYAN        6     0,max,max


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aaup - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aaup()
{ curl3 -0 -o ~/.bash_profile http://static.askapache.com/askapache-bash-profile.txt && dos2unix -dv ~/.bash_profile && ( rm -rf ~/{.bash_logout,.toprc,.lynxrc,.ncftp} || echo; echo; ) && aa_savehist && exec bash -l; }

#for DM in `cat /opt/domains.txt`; do dig @8.8.8.8 +nocl +nostats +nocomment +recurse +multiline +besteffort +additional +noqr -t ANY $DM; done

function oddeven()
{ [[ $# -eq 0 ]] && exec sed -e "1~2 s/^/`tput smso;`/; s/$/`tput setaf $(( $RANDOM % 7 + 1 ));tput rmso`/" || sed -e "1~2 s/^/`tput smso;`/; s/$/`tput setaf $(( $RANDOM % 7 + 1 ));tput rmso`/" "$@"; }


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# du1 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
du1()
{ find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -P5 -0 -iFF sh -c '( echo `du -sb "FF"` `du -sh "FF"` | sed -e "s%^\([0-9]*\)\ \([^ ]*\)\ \([^ ]*\).*$%\1 \3 \2%g" )' | sort -n | cut -d ' ' -f2,3 | command grep --color=always '^[0-9\.]*[GMK]'; }


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# du2 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
du2()
{ find . -maxdepth 1 -mindepth 1 -type f | tr ' ' "\n" | xargs -P20 -iFF sh -c 'sed -e "s%^\([0-9]*\)\ \([^ ]*\)\ \([^ ]*\).*$%\1 \3 \2%g" <<< $( echo "`( du -sb FF && du -sh FF ) | tr --squeeze \t\n `" )' | sort -n | tail -n 20 | awk '{print $2,$3}' | tr ' ' "\t";}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# vless - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function vless()
{
  [[ $# -eq 0 ]] && command vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' -
  [[ $# -eq 0 ]] || command vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' "$@"
}


#0111 ---x--x--x
#0110 ---x--x---
#0100 ---x------
#0000 ----------
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_find_exec - Function that finds executable files on directory or current directory
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_find_exec()
{ find -L ${1:-.} -type f -perm +0100 2>$N6 | xargs file | sed -e 's%^\([^:]*\):\([^,]*\).*$%\1:\2%g'; }



#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# curl1 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function curl1()
{ command curl -A 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5' -e -L -H 'Accept: */*' "$@"; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# curl2 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function curl2()
{
	(
	echo "\n\nurl_effective:\t\t%{url_effective}\ncontent_type:\t\t%{content_type}"
	echo "http_code:\t\t%{http_code}\t\tThe numerical code that was found in the last retrieved HTTPS page"
	echo "http_connect:\t\t%{http_connect}\t\tThe numerical code that was found in the last response from a proxy to a curl CONNECT request"
	echo "time_total:\t\t%{time_total}\t\tThe time will be displayed with millisecond resolution"
	echo "time_namelookup:\t%{time_namelookup}\t\tThe time, in seconds, it took from the start until the name resolving was completed"
	echo "time_connect:\t\t%{time_connect}\t\tThe time, in seconds, it took from the start until the connect to the remote host or proxy was completed"
	echo "time_pretransfer:\t%{time_pretransfer}\t\tThe time, in seconds, it took from the start until the file transfer is just about to begin. This includes all pre-transfer commands and negotiations to the particular protocols involved"
	echo "time_redirect:\t\t%{time_redirect}\t\tThe time, in seconds, it took for all redirection steps. time_redirect shows the complete execution time for multiple redirections"
	echo "time_starttransfer:\t%{time_starttransfer}\t\tThe time, in seconds, it took from the start until the first byte is just about to be transferred. This includes time_pretransfer and also the time the server needs to calculate the result"
	echo "size_download:\t\t%{size_download}\t\tThe total amount of bytes that were downloaded"
	echo "size_upload:\t\t%{size_upload}\t\tThe total amount of bytes that were uploaded"
	echo "size_header:\t\t%{size_header}\t\tThe total amount of bytes of the downloaded headers"
	echo "size_request:\t\t%{size_request}\t\tThe total amount of bytes that were sent in the HTTP request"
	echo "speed_download:\t\t%{speed_download}\tThe average download speed that curl measured for the complete download"
	echo "speed_upload:\t\t%{speed_upload}\t\tThe average upload speed that curl measured for the complete upload"
	echo "num_connects:\t\t%{num_connects}\t\tNumber of new connects made in the recent transfer"
	) |curl "$@" -w '@-'
}

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# curl3 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function curl3()
{
  ahave curl && ( curl -A 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5' -e -L -b ~/.curl_cookie.$$ --cookie-jar ~/.curl_cookie.$$ -H 'Accept: */*' "$@"; )
  ahave curl || ( command wget `sed -e 's/^-o /-O /g' -e 's/ -o / -O /g' -e 's/^--output /--output-file /g' -e 's/ --output / --output-file /g' <<< "$@"`; )
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# grepp - Function that searches current directory for match
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function grepp()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  export GREP_COLOR=`echo -en "\e[1;3$(( $RANDOM % 7 + 1 ))"`
  command grep -i --color=always "$@" -r .
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# grepc - Function shortcut for grep with color
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function grepc()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  export GREP_COLOR=`echo -en "\e[1;3$(( $RANDOM % 7 + 1 ))"`
  command grep --color=always "$@"
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# nob - Function remove blank lines from output
# cat file | nob
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function nob()
{ [[ $# -eq 0 ]] && exec grep -v ^$|sed -e '/[^ \t]\{1,\}/!d'; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# nobl - Function remove leading whitespace
# cat file | nobl
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function nobl()
{ [[ $# -eq 0 ]] && exec sed -e 's/^[ \t]*//'; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# nobt - Function remove trailing whitespace
# cat file | nobt
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function nobt()
{ [[ $# -eq 0 ]] && exec sed -e 's/[ \t]*$//'; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# nobb - Function to remove both leading and trailing whitespace
# cat file | nobb
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function nobb()
{ [[ $# -eq 0 ]] && exec sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/[^ \t]\{1,\}/!d'; }



function aa_hexdump()
{
  local EX
  [[ $# -eq 1 ]] && EX=exec
  [[ -f "$1" ]] && EX='cat "$1"'
   
  case ${2:-1} in
    0) $EX hexdump -C  ;;
    1) $EX hexdump -Cc  ;;
    2) $EX hexdump -Cx  ;;
    3) $EX hexdump -C -e '""  10/1 "'\''%_c'\''\t" "\n"' -e '"" 10/1 "0x%02x\t" "\n\n"'  ;;
    4) $EX hexdump -e '""  10/1 "'\''%_c'\''\t" "\n"'  ;;
    5) $EX hexdump -e '""  10/1 "'\''%_c'\''\t" "\n"' -e '"" 10/1 "0x%04x\t" "\n\n"'  ;;
    6) $EX hexdump -e '90/1 "%_p" "\n"'  ;;
    7) $EX hexdump -e '1/1 "%04_u" "%4_p" "   " 1/1 "%04x" "  " 1/1 "%04_c"  "\n"'  ;;
    8) $EX hexdump -v -e '"x" 1/1 "%02X" " "'  ;;
    9) $EX od -Ax -tx1 -v  ;;
   10) $EX od -t o1z -w1 -Ao -v  ;;
   11) $EX xxd -  ;;
   12) $EX xxd -c1  ;;
   13) $EX xxd -h  ;;
   14) $EX  ;;
  esac;
  
#o=1;i=1;while [[ "$i" -lt 256 ]];do pp="00$o";echo -en "\\0${pp: -3}";((i++,o++));((i % 8==0))&&((o+=2));((i % 64==0))&&((o+=20));done | od -t o1z -w2 -Ao -v
}










#nice mysqldump --opt --add-drop-table -u$_U -p$_P -h$_H $_N | (cd $BD; ionice -c3 -n7 nice gpg -evr connected -o $FS - &>$N6 ) & &>$N6
function nicest()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  local ncmd icmd='';
  
  ahave ionice && icmd='ionice -c3 -n7'
  ahave nice && ncmd='nice -n 19'
  $icmd $ncmd "$@"

  
  ahave ionice 
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# diffdirs  - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function diffdirs ()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  [[ "$#" -lt "2" ]] && echo "Usage: $FUNCNAME dir1 dir2" >&2 && return 2
  ahave colordiff && colordiff -urp -w $1 $2;
}





#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# wcdir - Function that outputs every dir in the currect directory, and how many files each contains
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function wcdir()
{  
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  find ${1:-.} -mindepth 1 -type d -print0 | xargs -0 -iFF sh -c 'echo `find "FF"/ -type f 2>/dev/null|wc -l;echo "FF"`' | sort -n | sed -e 's/^\([0-9]*\) \(.*\)$/ \1\t\2/g'
}





#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# locate1 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function locate1()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  command locate "$@" | xargs -iFF stat -c %a\ %A\ \ A\ %x\ \ M\ %y\ \ C\ %z\ \ %N FF ;
}




#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# figtest - Function to show all the variations figlet can do to a word
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function figtest()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME word" && return 2
  for a in /usr/share/figlet/*.flf; do r=`basename ${a%%.flf}`; echo -e "${r}"; figlet -t -f "$r" "$1"; done;
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# asetup_colors - Function to setup dircolors, PS1, and LS_COLORS
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function asetup_colors()
{
  create_colors
  
  ahave dircolors && eval "`dircolors -b`"
  
  export GREP_COLOR=`echo -en "\e[1;3$(( $RANDOM % 7 + 1 ))"`
  echo $R;

  [[ -r $HOME/.dircolors ]] && eval "`dircolors $HOME/.dircolors`" || dircolors --print-database > $HOME/.dircolors
  local L="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:*.tar=01;31:*.tgz=01;31:*.svgz=01;31:*.arj=01;31:*.taz=01;31"
  L="${L}:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31"
  L="${L}:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.mng=01;35"
  L="${L}:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35"
  L="${L}:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.cpio=01;31"
  export LS_COLORS="${L}:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.htaccess=01;31:*.htpasswd=01;31:*.htpasswda1=01;31:*config.php=01;31:*wp-config.php=01;31:";
}



declare -a AAPS
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_prompt - Function that creates prompt
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_prompt()
{

  N=$(( $RANDOM % 7 + 1 ));C2=`echo -en "\E[0m\E[3"${N}m`;C1=`echo -en "\E[0m\E[1;3"${N}m`;C3=`echo -en "\E[0m\E[1;37m"`

  AAPS[0]='\n\e[1;30m[\e[0;37m${SHLVL}\e[1;30m:\e[0;37m\j:\!\e[1;30m][${C1}\u${C2}@${C1}\h\e[1;30m:\e[1;37m${SSHTTY/\/dev\/}\e[1;30m]\e[0;37m[\e[0;37m\w\e[0;37m]\e[1;30m\n\[${R}\]\$ '
  AAPS[1]='\n\e[1;30m[\e[0;37m${SHLVL}\e[1;30m:\e[0;37m\j:\!\e[1;30m][${C1}\u${C2}@${C1}\h\e[1;30m:\e[1;37m${SSHTTY/\/dev\/}\e[1;30m]\e[0;37m[\e[0;37m\w\e[0;37m]\e[1;30m\n\[${R}\]\$ '
  AAPS[2]='\n\e[1;30m[\e[0;37m${SHLVL}\e[1;30m:\e[0;37m\j:\!\e[1;30m][\e[0;35m\u\e[1;35m@\e[0;35m\h\e[1;30m:\e[1;37m${SSHTTY/\/dev\/}\e[1;30m]\e[0;37m[\e[0;37m\w\e[0;37m]\e[1;30m\n\[${R}\]\$ '
  
  : ${PLVL=0};
  [[ "${#AAPS[@]}" -lt "$PLVL" || "${#AAPS[@]}" -eq "$PLVL" ]] && PLVL=0
  
  export PS1=${AAPS[$PLVL]} && (( PLVL++ )) && export PLVL
  echo "PLVL=$PLVL"
}



#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# create_colors - Function that creates the colors in the CC array 
#
# 30 - Black, 31 - Red, 32 - Green, 33 - Yellow, 34 - Blue, 35 - Magenta, 36 - Blue/Green, 37 - White, 30/42 - Black on Green '30\;42'
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function create_colors()
{
  for i in `seq 0 7`;do ii=$(($i+7));CC[$i]="\033[1;3${i}m";CC[$ii]="\033[0;3${i}m";done;CC[15]="\033[30;42m"
  export R=`tput sgr0`
  export X=$'\033[1;37m'
  export CC;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# test_colors - Function to output all colors stored in the CC array
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function test_colors(){ echo -e "$R"; ahave tput && tput sgr0; for ((i=0; i<=${#CC[@]} - 1; i++)); do echo -e "${CC[$i]}[$i]\n$R"; done; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_show_all_colors - Function to show all available colors, maybe your term supports alot
# http://frexx.de/xterm-256-notes/
# http://frexx.de/xterm-256-notes/data/colortable16.sh
# http://www.vim.org/scripts/script.php?script_id=1349
# http://www.linuxjournal.com/article/1124
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_show_all_colors()
{
  for c in `seq 0 255`;do t=5;[[ $c -lt 108 ]]&&t=0;for i in `seq $t 5`;do echo -e "\e[0;48;$i;${c}m|| $i:$c `seq -s+0 $(($COLUMNS/2))|tr -d '[0-9]'`\e[0m";done;done;
  tput init
  tput reset
  echo
  echo Table for 16-color terminal escape sequences.
  echo Replace ESC with \\033 in bash.
  echo
  echo "Background | Foreground colors"
  echo "---------------------------------------------------------------------"
  
  for((bg=40;bg<=47;bg++)); do for((bold=0;bold<=1;bold++)) do echo -en "\033[0m"" E[${bg}m   | "; for((fg=30;fg<=37;fg++)); do [[ $bold == "0" ]] && echo -en "\033[${bg}m\033[${fg}m [${fg}m  " || echo -en "\033[${bg}m\033[1;${fg}m [1;${fg}m"; done; echo -e "\033[0m"; done; done
    
  echo
  echo
}







#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# clean_exit - Function to run on clean exit
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function clean_exit() { lin 0;lin 1;lin 2 "COMPLETED SUCCESSFULLY";lin 1;lin 3; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# dirty_exit - Function to run on bad exit
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function dirty_exit() { echo "See ya..";sleep 1;exit; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# get_latest_revision - Function to get latest revision of svn repository
# 1 - URL of repository - Defaults to http://svn.automattic.com/wordpress/trunk
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function get_latest_revision()
{
  local URL=${1:-http://svn.automattic.com/wordpress/trunk}
  svn info $URL | grep ^Rev|sed -e 's/Revision: \([0-9]*\)/\1/g';
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# get_crypt_user - Function to get encryption user to use for encryption/decryption
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function get_crypt_user()
{
  ahave gpg || return;
  local U=`gpg --list-keys|sed -e '/^uid /!d' -e 's/^uid[ ]*\(.*\)/\1/g'` || unknown; [[ $# -ne 0 ]] && U=${U//\<*}; echo -n $U;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_random_under - Function echos a random number between 1 and $1
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_random_under()
{
  echo $(( $RANDOM % ${1:-$RANDOM} + 1 ));
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# uniqf - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function uniqf()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  awk '!($0 in a) {a[$0];print}' "$1";
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# sleeper - Function that sleeps and outputs dots until process id is done running
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function sleeper()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME <process id>" >&2 && return 2
  echo -en "\n${2:-.}"; while `command ps -p $1 &>$N6`; do echo -n "${2:-.}"; sleep ${3:-1}; done; echo;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_isalpha  - Function Tests whether *entire string* is alphabetic.
# FROM:  http://tldp.org/LDP/abs/html/
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_isalpha ()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME str" >&2 && return 2
  case $1 in *[!a-zA-Z]*|"") return -1; ;; *) return 0; ;; esac;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_isdigit  - Function tests whether *entire string* is numerical integer variable.
# FROM:  http://tldp.org/LDP/abs/html/
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_isdigit ()
{
  case $1 in *[!0-9]*|"") return -1; ;; *) return 0; ;; esac;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# find_symlinks - Function to find symlinks in a given directory or current directory
# FROM http://tldp.org/LDP/abs/html/loops1.html#SYMLINKS
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function find_symlinks()
{
  # Null IFS means no word breaks 
  local O=$IFS;IFS='';for file in "$( find ${1:-`pwd`} -type l )"; do echo "$file"; done | sort;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# arepeat - Function that repeats evaluated expressions x number of times
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function arepeat()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  local i max=$1; shift; for ((i=1; i <= max ; i++)); do eval "$@"; done;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# cuttail - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function cuttail()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  sed -n -e :a -e "1,${2:-10}!{P;N;D;};N;ba" $1;
}








#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_ips - Function that uses the ip command to show all inet ips
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_ips()
{
  ahave ip && ip -o -f inet addr 2>&1 | sed -e 's/.*inet \([^/]*\).*/\1/g' | sort -u
  ahave ss && ss -n 2>&1 | sed -e 's/[^:]*\ \([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)\:.*/\1/' -e '/^\([^0-9]\|127\.\|10\.\|172\.\)/d' | sort -u
  [[ -f "$HOME/.cpanel/datastore/_sbin_ifconfig_-a" ]] && sed -e '/inet/!d' -e 's/.*addr:\([0-9\.]*\).*/\1/g' "$HOME/.cpanel/datastore/_sbin_ifconfig_-a" | sort -u
  sed -e 's/^\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/\1/' -e '/^\([^0-9]\|127\.\|10\.\|172\.\|$\)/d' /etc/hosts |sort -u
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# print_ascii_chart - Function that prints the ascii table
# print_ascii_chart | cat -ts
# print_ascii_chart | hexdump
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function print_ascii_chart()
{
  #local p pp o i=1; o=1;
  #while [[ $i -lt 256 ]];do p="    $i";echo -n "${p: -5}  ";pp="00$o";echo -e "\\0${pp: -3}";((i++,o++));((i % 8==0))&&((o+=2));((i % 64==0))&&((o+=20));done
  #for i in `seq 0 256`; do echo -en "\n$i: ";printf \\$(($i/64*100+$i%64/8*10+$i%8)); done
  for i in `seq 0 256`; do echo -e "\\0$(( $i/64*100 + $i%64/8*10 + $i%8 ))"; done
}

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_functions - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_functions()
{
  local F=`for i in $(declare -F | sed -e 's/declare -f //g'); do echo $i; done| sed -e :a -e 's/^.\{1,25\}$/& /;ta'|tr ' ' '\032'`
  i=1; for f in ${F}; do echo -en "$f"; (( $i % 4 ==0 )) && echo -en "\n";  i=$(( $i + 1)); done | tr '\032' " "
}

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_aliases - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_aliases()
{
  local F=`for i in $(alias|awk -F= '{print $1}');do echo $i;done|sed -e :a -e 's/^.\{1,15\}$/& /;ta'|tr ' ' '\032'`; i=1;
  for f in ${F}; do echo -en "$f"; (( $i % 4 ==0 )) && echo -en "\n"; i=$(( $i + 1)); done | tr '\032' " ";
}








#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_mkdir - Function that makes directories
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_mkdir()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2

  local e=0; for f in ${1+"$@"};do set fnord `echo ":$f"|sed -e 's/^:\//%/' -e 's/^://' -e 's/\// /g' -e 's/^%/\//'`;shift;p=;for d in ${1+"$@"};do p="$p$d";
  case "$p" in -*)p=./$p; ;; ?:)p="$p/";continue ;; esac; [[ ! -d "$p" ]] && mkdir -v "$p"||e=$?;p="$p/";done;done;return $e;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# set_window_title - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function set_window_title()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  echo -n -e "\033]0;$*\007";
}







#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# pd - Function Prints message notifying user of end of the current task
# 1 - Text - Defaults to DONE
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function pd() { echo -e  "\n ${CC[15]} ${1:-DONE} $R\n\n"; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# cont - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function cont() { local ans; echo -en "\n\n ${CC[15]}[ ${1:-Press any key to continue} ]$R\n\n"; read -n 1 ans; aa_beep 1; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# do_sleep  - Function Sleeps until global process PID $RJ does not exist
# 
# 1
# 2 - Length of pause between output
# 3 - Character to show progress - Defaults to .
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function do_sleep () { local E D; echo -en "${CC[6]}${3:-.}"; while `command ps -p $RJ &>$N6`; do sleep ${2:-3}; echo -en "${3:-.}"; done; echo -e "${CC[0]}" && sleep 1 && pd; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_sleep  - Function Sleeps until global process PID $RJ does not exist
# 
# 1
# 2 - Length of pause between output
# 3 - Character to show progress - Defaults to .
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_sleep () { echo -en "${CC[6]}${3:-.}"; while `command ps -p $1 &>/dev/null`; do echo -n "${3:-.}"; sleep ${3:-1}; done; echo -e "$R$X" && sleep 1 && pd; }


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_num_procs - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_num_procs()
{ echo -n `command ps aux|wc -l`; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_free_mem - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_free_mem()
{ echo -n "`[[ -r /proc/meminfo ]] && sed '/^MemFree: */!d; s///;q' /proc/meminfo`"; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_current_users - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_current_users()
{ echo -n "`command who -q |sed '/^# users=\([0-9]*\).*/!d; s//\1/;q'`"; }

# The average number of jobs running, followed by the number of runnable processes and the total number of processes (if your kernel is recent enough), followed by the PID of the last process run (idem).
#echo -n "`[[ -r /proc/loadavg ]] && sed -e 's/^\(.*\)$/[ \1 ]/' /proc/loadavg`" 
#echo -n "[ `command uptime | sed -e 's/.*: \([^,]*\).*/\1/'` / `aa_num_procs` ]"
# uptime1
function uptime1()
{ command uptime |sed '/.*,  \([0-9]*\) users,  load average: \(.*\)/!d; s//[ \2, \1 users ]/;q'; }


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# ex - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function ex ()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  until [[ -z "$1" ]]; do
    if [[ -f "$1" ]] ; then
      pm "Extracting $1 ..."
	  case $1 in
		*.tar.bz2) tar xjf $1 ;;
		*.tar.gz)  tar xzf $1 ;;
		*.tar)     tar xf $1 ;;
		*.tbz2)    tar xjf $1 ;;
		*.tgz)     tar xzf $1 ;;
		*.bz2)     bunzip2 $1 ;;
		*.rar)     unrar x $1 ;;
		*.gz)      gunzip $1 ;;
		*.zip)     unzip $1 ;;
		*.Z)       uncompress $1 ;;
		*.7z)      7z x $1 ;;
		*)        pm "Don't know how to extract '$1'" ;;
	  esac;
    else
      pm "'$1' is not a valid file"
    fi
    shift
  done

}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# yes_no - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function yes_no()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME Question" >&2 && return 2
  local a YN=65; echo -en "${1:-Answer} [Y/n] ?"; read -n 1 a; case $a in [yY]) YN=0; ;; esac; return $YN;
}
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# yn - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function yn()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  local a YN=65; echo -en "\n ${CC[6]}@@ ${1:-Q} $R$X[y/N] ?$R"; read -n 1 a; echo; case $a in [yY]) echo -n "Y"; YN=0; ;; *) echo -n "N"; ;; esac; return $YN;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# lin - Function that prints various lines
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function lin()
{
  local L2 L1='__________________________________________________________________________'
  case ${1:-1} in
    0) echo -e "\n ${CC[0]}${L1}"; ;;
    1) L2=`echo '                                                                          '`;echo -e "${CC[0]}|${CC[15]}${L2}${CC[0]}|"; ;;
    2) echo -en "${CC[0]}|${CC[15]}"; echo -en "${2:-1}" | sed -e :a -e 's/^.\{1,72\}$/ & /;ta' -e "s/\(.*\)/\1/";   echo -e "${CC[0]} |"; ;;
    3) echo -e "${CC[0]} ${L1} $R$X\n\n"; ;;
  esac;
}




#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# pwd - Function that prints the working directory
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function pwd(){ command pwd -LP "$@"; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# kill_jobs - Function that kills with a SIG 9 SIGKILL all currently running jobs
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function kill_jobs() { for i in `command jobs -p`; do kill -9 $i; done; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_beep - Function that beeps $1 amount of times every second using term escapes
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_beep() { local i; for i in `seq 1 ${1:-5}`;do echo -en "\a" && sleep 1; done; }





#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# l - Function that displays a directory listing in non-long mode
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function l() { command ls -AhFp $AAC "$@"; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# la - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function la() { du *|awk '{print $2,$1}'|sort -n|tr ' ' "\t"; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# ll - Function that shows the directory listing
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function ll() { command ls -lABls1c $AAC "$@"; }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_getsrc - Function that downloads a srcfile into the dist dir, then unarchives it and cds into it 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_getsrc()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME <url>" >&2 && return 2
  
  [[ -z "$CPPFLAGS" ]] && pm "Setting CPPFLAGS" && export CPPFLAGS="-I/usr/local/include/libxml2 -I/opt/libiconv/include"
  [[ -z "$LD_FLAGS" ]] && pm "Setting LD_FLAGS" && export LD_FLAGS="-L/usr/local/lib -L/usr/local/lib/python2.4/site-packages -L/usr/local/lib -lxml2 -lz -L/opt/libiconv/lib -liconv -lm"

  aa_err() { echo $'\a'; local s; echo -en "\n [ ${1:-Press any key to continue} ]\n"; read -n 1 s; }
  aa_install() { ./configure --help; ./configure --prefix=/usr/local "$*" && make -j3 && sudo make install || aa_err; echo -en "\a"; }

  local OD=`pwd -L`; local FN=$(echo $1 | sed -e 's/^.*\/\([^\/]\{3,\}\)$/\1/g'); local SN=$(echo $FN |  sed -e 's/\(.\{1\}\)\([^-.]\{1,\}\).*/\1\2/g');
  echo -e "OD: $OD \n1: $1 \nFN: $FN \nSN: $SN" && sleep 1

  cd /opt/dist
  ( curl -# -L -f -b c.txt --cookie-jar c.txt -m 400 -O -H 'Accept: */*' -s -S -A 'Mozilla/5.0 (Windows NT 5.1; en-US; rv:1.9.1.5) Gecko/2009 Firefox/3.5.5' -e "$1" --url "$1" || v_err "CURL FAILED for $1"; )

  [[ -f "$FN" ]] && ex "$FN" || aa_err "EXTRACTING FAILED for $FN, go manual it"
  [[ -d "/opt/$SN" ]] && mv -v /opt/$SN /opt/.old-$SN;
  mv -v /opt/source/`echo $1|sed -e 's/.*\/\(.*\)\.\([tgz7bar2v]*\)\(\.[tgz7bar2v]*\)$/\1/g'` /opt/$SN || aa_err "Please mv $1 to /opt/$SN"
  cd /opt/$SN && command ls -lABls1c $AAC && aa_install
  cd $OD
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# stat1 - Function that displays a verbose stat for all files in current directory, or files passed in $1
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function stat1()
{
  local D=${1:-$PWD/*}; stat -c %a\ %A\ \ A\ %x\ \ M\ %y\ \ C\ %z\ \ %N ${D} |sed -e 's/ [0-9:]\{8\}\.[0-9]\{9\} -[0-9]\+//g' |tr  -d "\`\'"|sort -r;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# stat2 - Function that displays a verbose stat for all files in current directory, or files passed in $1
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function stat2()
{
  local D=${1:-$PWD/*}; stat -c %a\ %A\ \ A\ %x\ \ M\ %y\ \ C\ %z\ \ %N ${D} |sed -e 's/\.[0-9]\{9\} -[0-9]\+//g'|tr  -d "\`\'"|sort -r;
}





#--=--=--=--=--=--=--=--=--=--=--#
# processes
#==-==-==-==-==-==-==-==-==-==-==#


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# psu - Function that shows the processes of the user
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function psu()
{
  command ps -Hcl -F S f -u ${1:-$USER};
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# ps - Function that displays the process environment, or if args uses the normal ps
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function ps()
{
  [[ -z "$1" ]] && command ps -Hacl -F S -A f && return; command ps "$@";
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# make_nice - Function that makes a process have a nice CPU slice
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function make_nice()
{
  ahave renice || return;
  local thenicelevel thepid
  thepid=${1:-$$}
  thenicelevel=${2:-19}
  pm "Making process $thepid $thenicelevel nice."
  pm 0 0
  command renice $thenicelevel -p $theppid
  pd
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# make_ionice - Function that makes the process ioniced
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function make_ionice()
{
  ahave ionice || return;
  local theclass thenicelevel thepid
  thepid=${1:-$$}
  theclass=${2:-3}
  thenicelevel=${3:-7}
  pm "Making IONice class: $theclass, nicelevel: $thenicelevel, process: $thepid"
  pm 0 0
  command ionice -c$theclass -n$thenicelevel -p $thepid
  pd
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_ps_env - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_ps_env() 
{
  pm "PROCESS ENVIRONMENTS"
  ( command ps aux | command grep ${USER:0:3} | command awk '{print $2}' | xargs -t -ipid /bin/sh -c 'test -r /proc/pid/environ && cat /proc/pid/environ | tr "\000" " "' )
  
  ps aux | grep dhapache |awk '{print $2 }'| xargs -t -ipid find /proc/pid -type f 2>$N6 | xargs -iRR cat RR
}


function aa_ps_cmdlines()
{
  pm "CMDLINES" 
  ( command ps axo pid|sed 1d| xargs -ipid sh -c '[[ $PPID -ne pid && -r /proc/pid/cmdline ]] && ( echo -en "\n[pid] CMDLINE: "; cat /proc/pid/cmdline | tr "\000" " " | tr "\033" "E" )' )
}




#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# procinfo1 - Function that displays a more verbose procinfo
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function procinfo1()
{
  PI=($(strace -s1 procinfo -a 2>&1|sed -e '/^op/!d' -e '/pro/!d' -e '/= -1/d'|sed -e 's%o.*"/proc/\(.*\)".*% \1%g'));
  for i in ${PI[*]}; do echo -e "\n---===[  /proc/$i  ]\n" && cat /proc/$i && echo -e "\n\n"; done
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# pss - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function pss()
{
  local U PPS PL PX PXX UUS=( $(command ps uax|awk '{print $1}'|command tail -n +2|sort|uniq) ); UL=$((${#UUS[@]} - 1))
  exec 6>&1; exec > ~/proc.$$
  ps aux | grep ${USER:0:3} | awk '{print $2}' | xargs -t -ipid cat /proc/pid/environ
  for UX in $(seq 0 1 $UUS); do U=${UUS[$UX]}; PPS=( $(pgrep -u ${U}) ); PL=$((${#PPS[@]} - 1));
   for PX in $(seq 0 1 $PL); do PXX=${PPS[$PX]};echo -e "\n\n\n----- PROCESS ID: ${PXX} -----\n\n";cat /proc/${PXX}/cmdline 2>$N6 || echo;echo -e "\n\n"; command tree -Csuflapi /proc/Q/${PXX};done
  done
  exec 1>&6 6>&-; cat ~/proc.$$ | more
}





##################################################################################################################################################################################
# history setup
##################################################################################################################################################################################


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# uniq2 - Function - warning, only works for small files.. it can mess it up bigtime
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function uniq2() 
{ 
  [[ -f "$1" ]] && sed = $1 | sed -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; s/\n//; h; P';
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# asetup_history - Function 
#   history [n]
#   history -c
#   history -d offset
#   history -anrw [filename]
#   history -p arg [arg ...]
#   history -s arg [arg ...]
#
#   With no options, display the command history list with line numbers. Lines listed with a * have been modified. An argument of n lists only the 
#   last n lines. If filename is supplied, it is used as the name of the history file; if not, the value of HISTFILE is
#   used. Options, if supplied, have the following meanings:
#
#   -c Clear the history list by deleting all the entries.
#   -d offset Delete the history entry at position offset.
#   -a Append the ``new'' history lines (history lines entered since the beginning of the current bash session) to the history file.
#   -r Read the contents of the history file and use them as the current history.
#   -w Write the current history to the history file, overwriting the history file's contents.
#   -s Store the args in the history list as a single entry. The last command in the history list is removed before the args are added.
#
#   -n
#   Read the history lines not already read from the history file into the current history list. These are lines appended to the history 
#   file since the beginning of the current bash session.
#
#   -p
#   Perform history substitution on the following args and display the result on the standard output. Does not store the results in the 
#   history list. Each arg must be quoted to disable normal history expansion.
#
#   The return value is 0 unless an invalid option is encountered, an error occurs while reading or writing the history file, an invalid 
#   offset is supplied as an argument to -d, or the history expansion supplied as an argument to -p fails.
#
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function asetup_history()
{

#   HISTFILE - The name of the file in which command history is saved (see HISTORY below). If unset, the command history is not saved when an interactive shell exits.
  export HISTFILE=${HISTFILE:-$HOME/.bash_history}

#   HISTCONTROL
#   If set to a value of ignorespace, lines which begin with a space character are not entered on the history list. If set to a value of ignoredups, lines matching the last 
#   history line are not entered. A value of ignoreboth combines the two options. If unset, or if
#   set to any other value than those above, all lines read by the parser are saved on the history list, subject to the value of HISTIGNORE. This variable's function is 
#   superseded by HISTIGNORE. The second and subsequent lines of a multi-line compound command are
#   not tested, and are added to the history regardless of the value of HISTCONTROL. 
  export HISTCONTROL=${HISTCONTROL:-'ignoreboth'};
  
#   HISTSIZE
#   The number of commands to remember in the command history (see HISTORY below). The default value is 500.
  export HISTSIZE=500
  
#   HISTFILESIZE
#   The maximum number of lines contained in the history file. When this variable is assigned a value, the history file is truncated, if necessary, to contain no more than 
#   that number of lines. The default value is 500. The history file is also truncated to this
#   size after writing it when an interactive shell exits.
  export HISTFILESIZE=500
   
  
#   HISTIGNORE
#   A colon-separated list of patterns used to decide which command lines should be saved on the history list. Each pattern is anchored at the beginning of the line and must 
#   match the complete line (no implicit `*' is appended). Each pattern is tested against the
#   line after the checks specified by HISTCONTROL are applied. In addition to the normal shell pattern matching characters, `&' matches the previous history line. `&' may be 
#   escaped using a backslash; the backslash is removed before attempting a match. The second
#   and subsequent lines of a multi-line compound command are not tested, and are added to the history regardless of the value of HISTIGNORE.
  export HISTIGNORE='clear:ls:ll:updatedb:top:h2:h1:h3:dir:cd ..:date:exit'
  
  
  
#   HISTTIMEFORMAT
#   If this variable is set and not null, its value is used as a format string for strftime(3) to print the time stamp associated with each history entry displayed 
#   by the history builtin. If this variable is set, time stamps are written to the history file so they may be preserved across shell sessions. This uses the history 
#   comment character to distinguish timestamps from other history lines.
#   unsetting this keeps timestamps out of the history files, as only newer bash versions support this
  unset HISTTIMEFORMAT



  # this is the directory for your history master files
  HISTFILEMASTER_DIR=$HOME/backups/.history
  [[ ! -d "$HISTFILEMASTER_DIR/" ]] && mkdir -pv $HISTFILEMASTER_DIR

  
  # if no readable HISTFILE then create one with current history
  [[ ! -r ${HISTFILE} ]] && history -w $HISTFILE


  # if no HISTFILEMASTER then create one with current history
  HISTFILEMASTER=${HISTFILEMASTER_DIR}/combined.log
  [[ ! -f $HISTFILEMASTER ]] && history -r && history -w $HISTFILEMASTER && history -c && echo "" > $HISTFILE
  export HISTFILEMASTER
  
 
 
  HISTFILEMASTER_C=$HISTFILEMASTER_DIR/combined-uniq.log;
  [[ ! -f "$HISTFILEMASTER_C" ]] && echo "" > $HISTFILEMASTER_C
  export HISTFILEMASTER_C
  

  #[[ $SHLVL -eq 1 ]] && cat $HISTFILE $HISTFILEMASTER >> $HISTFILEMASTER_C && 
  #ahave nice && nice -n 19 sed -i -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; s/\n//; h; P' $HISTFILEMASTER_C &
  #[[ $SHLVL -eq 1 ]] && eval $(echo "sh -c 'cd $HISTFILEMASTER_DIR; echo *|tr \" \" \"\n\"
  #|xargs -iFF sed -i -e \"s/^[ \t]*//;s/[ \t]*$//\" FF && echo *|tr \" \" \"\n\"
  #|xargs -iFF sed -i -e \"/./!d\" FF && echo *|tr \" \" \"\n\"|xargs -iFF sed -i -n \"/^.\{10\}/p\" FF'" ) &>$N6 & &>$N6
}


function histfilemaster()
{
  set -vx;
  history -a
  [[ "`wc -l < $HISTFILE`" -gt "$HISTSIZE" ]] && (
     cat $HISTFILE >> $HISTFILEMASTER;
     cat $HISTFILE > `date +$HISTFILEMASTER_DIR/%m-%d-%y.history`
	 cat $HISTFILE $HISTFILEMASTER_C | sort | uniq > $HISTFILEMASTER_DIR/hc.tmp
	 [[ "`wc -l < $HISTFILEMASTER_DIR/hc.tmp`" -gt "`wc -l < $HISTFILEMASTER_C`" ]] && mv $HISTFILEMASTER_DIR/hc.tmp $HISTFILEMASTER_C || cat $HISTFILE >> $HISTFILEMASTER_C;
	 echo "" > $HISTFILE 
  )
  set +vx;
}


function aa_uniqhistory()
{
  ( echo $HISTFILE; find $HISTFILEMASTER_DIR -type f 2>$N6 ) | xargs -iFFF cat FFF 2>$N6 | sed -e 's/^[ \t]*//;s/[ \t]*$//' -e '/[^ \t]\{1,\}/!d' | tr --squeeze ' ' | sort -u
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# exitall - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# no matter how many SHLVL's deep you are, this kills all so you don't have to exit out of them all
function exitall()
{ aa_savehist; pkill -9 -t "${SSH_TTY/\/dev\/}"; }


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_savehist - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_savehist()
{ history ${HISTCMD:-5000} | sed -e 's/^[ 0-9]*\(.*\)/\1/g' | tee -a $HISTFILEMASTER_C >> $HISTFILEMASTER; cat $HISTFILE | tee -a $HISTFILEMASTER_C >> $HISTFILEMASTER; history -w; echo; }







#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# h2 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function h2()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME query" >&2 && return 2
  command grep -h "$@" $HISTFILEMASTER_C
}
function h2i()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME query" >&2 && return 2
  command grep -h -i "$@" $HISTFILEMASTER_C
}
function h2c()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME query" >&2 && return 2
  export GREP_COLOR=`echo -en "\e[1;3$(( $RANDOM % 7 + 1 ))"`
  command grep --color=always -h "$@" $HISTFILEMASTER_C
}









#ionice -c3 -n7 nice mysqldump --opt --add-drop-table -u$_U -p$_P -h$_H $_N | (cd $BD; ionice -c3 -n7 nice gpg -evr connected -o $FS - &>$N6 ) & &>$N6

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# rmb - Function that removes an entire directory forcefully but in the background
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function rmb()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME dirnametoremove" >&2 && return 2
  ( ( command rm -rf "$@" >&$N6 && pd "Finished $FUNCNAME $@" ) & );
}



#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# tard - Function that removes an entire directory forcefully but in the background
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function tard()
{
  [[ "$#" -lt "2" ]] && echo "Usage: $FUNCNAME dest-file (auto adds tgz" >&2 && return 2
  #yn "Tarring $2 to $1" && ( ( command tar -cpf "$1" "$2" &>$N6 ) & ) 
  pm "Tarring $2 to $1" && ( ( command tar -cpf "$1" "$2" >&$N6 ) & )
}

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# tarr - Function that removes an entire directory forcefully but in the background
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function tarr ()
{ pm "Tarring $1 to $1.rz" && ( ( command tar -cpf "$1.tar" "$1" >&$N6; [[ -f "$1.rz" ]] && command rm -vf "$1.rz"; command rzip -0 "$1.tar" && pd "Finished $1.rz" ) & ); }






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# nh - Function to run command detached from terminal and without output
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
nh()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME <command>" >&2 && return 2
  nohup "$@" &>$N6 & echo;
}










#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# dos2unixx - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function dos2unixx()
{
 [[ $# -eq 0 ]] && exec tr -d '\015\032' || [[ ! -f "$1" ]] && echo "Not found: $1" && return
 for f in "$@"; do
   [[ ! -f "$f" ]] && continue
   tr -d '\015\032' < "$f" > "$f.t" && cmp "$f" "$f.t" >$N6 && rm -f "$f.t" || ( touch -r "$f" "$f.t" && mv "$f" "$f.b" && mv "$f.t" "$f" && rm -f "$f.b" ) &>$N6
 done
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# lin - Function that prints various lines
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function lin()
{
  local C3=`echo -en "\E[0m\E[1;37m"`;
  local L2 L1='__________________________________________________________________________'
  case ${1:-1} in
    0) echo -e "\n ${CC[0]}${L1}"; ;;
    1) L2=`echo '                                                                          '`;echo -e "${CC[0]}|${C3}${L2}${CC[0]}|"; ;;
    2) echo -e "${CC[0]}|${C3} $(echo "${2:-1}" | sed -e :a -e 's/^.\{1,71\}$/ & /;ta' -e "s/\([ \t]*\)=\(.*\)=\([ \t]*\)/\1 \2 \3/g" )${CC[0]}|"; ;;
    3) echo -e "${CC[0]} ${L1} $R${CC[0]}\n\n"; ;;
  esac;
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# ascript_title - Function that shows the title of the script
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function ascript_title()
{
ahave tput && tput clear && tput cup 1;
N=$(( $RANDOM % 7 + 1 ));C2=`echo -en "\E[0m\E[3"${N}m`;C1=`echo -en "\E[0m\E[1;3"${N}m`;C3=`echo -en "\E[0m\E[1;37m"`;lin 0;
echo -e "| ${C1}                   ___       __    ___                 __               ${CC[0]} |";
echo -e "| ${C1}                  / _ | ___ / /__ / _ | ___  ___ _____/ /  ___          ${CC[0]} |";
echo -e "| ${C2}                 / __ |(_-</  '_// __ |/ _ \/ _ \`/ __/ _ \/ -_)         ${CC[0]} |";
echo -e "| ${C2}                /_/ |_/___/_/\_\/_/ |_/ .__/\_,_/\__/_//_/\__/          ${CC[0]} |";
echo -e "| ${C2}                                     /_/                                ${CC[0]} |";
lin 1;lin 2 "=${1:-$AAPN}=" | sed -e "s/=\(.*\)=/`tput setaf $N;tput smso`\1`tput setaf 0;tput rmso`/g";
lin 2 "v: ${2:-$AAPV} - ${3:-$AAPT}"; lin 1; lin 3; tput cup $LINES;
}


ascript_title ()
{
    ahave tput && tput cup 0 3;
    clear;
    lin 0;
    echo -e "| ${C1}                ___       __    ___                 __                  ${CC[0]} |";
    echo -e "| ${C1}               / _ | ___ / /__ / _ | ___  ___ _____/ /  ___             ${CC[0]} |";
    echo -e "| ${C2}              / __ |(_-</  '_// __ |/ _ \/ _ \`/ __/ _ \/ -_)            ${CC[0]} |";
    echo -e "| ${C2}             /_/ |_/___/_/\_\/_/ |_/ .__/\_,_/\__/_//_/\__/             ${CC[0]} |";
    echo -e "| ${C2}                                  /_/                                   ${CC[0]} |";
    lin 1;
    lin 2 "${USER} ";
    lin 2 "${1:-$AAPN} ";
    lin 2 "Version ${2:-$AAPV} - Built: ${3:-$AAPT} ";
    lin 3
}



#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_motd - Function that shows the message of the day, if available
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_motd()
{
  [[ -r /etc/motd && `cat /etc/motd |wc -l` -gt 7 ]] && ( echo -e "\n\n${CC[2]}`head -n 7 /etc/motd | tail -n 6`${R}\n" ) && return
  ahave figlet && figlet $HOSTNAME
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_weather - Function that shows the weather for the server, if IP is found
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_weather()
{
  ahave lynx || return;
  local city weather=$HOME/.weather
  echo -e "${CC[3]}";
  local res=`pkill -9 -f 15m &>$N6 || echo -n`
  [[ -r $weather ]] && cat $weather && ( ( sleep 15m && command rm $HOME/.weather &>$N6 ) & )  
  
  [[ ! -r $weather ]] && (
( ( city=`lynx -dump http://api.hostip.info/get_html.php|sed -e '/^City/!d' -e 's/City: \([^,]*\), \(.*\)/\1+\2/g'`\
&& lynx -dump "http://www.google.com/search?hl=en&q=weather+${city}"|sed -n '/Weather for/,/Search Res/p'|\
tr -d '\260' | sed -e '/iGoogle/d' -e 's/^[ \t]*//;s/[ \t]*$//' | sed '$d' | head -n 6 >$weather ) & &>/dev/null )
)
  echo -e $R;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_calendar - Function that shows the calendar, if available
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_calendar()
{
  [[ -d /usr/share/calendar/ ]] && echo -en "\n${CC[4]}" && ( sed = $(echo /usr/share/calendar/calendar*) | sed -n "/$(date +%m\\/%d\\\|%b\*\ %d)/p" ) && echo -en "${R}";
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_fortune - Function that shows the fortune, if available
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_fortune()
{
  local FORTUNE=`command type -P fortune`
  [[ -x $FORTUNE ]] && echo -en "\n${CC[5]}" && $FORTUNE -s && echo -en "${R}";
  [[ -x $FORTUNE ]] && echo -en "\n${CC[6]}" && $FORTUNE -s && echo -en "${R}";
  [[ -x $FORTUNE ]] && echo -en "\n${CC[7]}" && $FORTUNE -s && echo -en "${R}";
  [[ -x $FORTUNE ]] && echo -en "\n${CC[8]}" && $FORTUNE -s && echo -e "${R}";
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# askapache - Function to display information about the current machine
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function askapache()
{
  ascript_title;
  aa_motd;
  aa_weather

  ahave who && pm "Users" && pm "Logged In" 3; command who -ar -pld && pm "Current Limits" 3;command ulimit -a

  pm "Machine stats"; ahave uptime && pm "uptime" 3 && command uptime; [[ -d /proc ]] && [[ -f /proc/meminfo ]] && cat /proc/meminfo
  ahave who && pm "Users" 3 && command who
  
  pm "Networking"
  ahave ip && pm "interfaces" 3 && ip -o addr|sed -e 's/ \{1,\}/\t/g'
  [[ -r /proc/net/sockstat ]] && pm "Sockets" 3 && head -n 2 /proc/net/sockstat
  ahave ss && pm "Networking Stats" 3 && ss -s; ahave netstat && pm "Routing Information" 3 && netstat -r

  pm "Disk"; pm "Mounts" 3; command df -hai
  #[[ -d /sys/block/ ]] && pm "IO Scheduling" 3; for d in /sys/block/[a-z][a-z][a-z]*/queue/*; do [[ -d $d ]] && tree $d; echo "$d => $(cat $d)";done
  ahave iostat && pm "I/O on Disks" && iostat -p ALL

  pm "Processes"; pm "process tree" 3;  command ps -HAcl -F S -A f | uniq -w3
  ahave procinfo && pm "procinfo" 3 && procinfo|head -n 13|tail -n 11
  
  #procinfo1
  
  pm "Functions"; aa_functions
  pm "Aliases"; aa_aliases
}
















##################################################################################################################################################################################
###
###  MAIN - Runs on exec
###
##################################################################################################################################################################################
[[ -f $HOME/.bash_login ]] && . $HOME/.bash_login

[[ ! -f $HOME/.bash_logout ]] && (
cat >$HOME/.bash_logout <<_AABASHLOGOUTTXT
#!$SHELL
exit_status=\$?
echo "SAVING HISTORY..."
history \${HISTCMD:-5000} | sed -e 's/^[ 0-9]*\(.*\)/\1/g' | tee -a \$HISTFILEMASTER_C >> \$HISTFILEMASTER;
cat \$HISTFILE | tee -a \$HISTFILEMASTER_C >> \$HISTFILEMASTER;
history -w
{ echo -e "--- [\$exit_status \$?] LINENO:\$LINENO \$SECONDS seconds" >&2; }
exit \$exit_status
_AABASHLOGOUTTXT
)


ahave top && [[ ! -f $HOME/.toprc ]] && (
cat >$HOME/.toprc <<_AATOPRC
RCfile for "top with windows"           # shameless braggin'
Id:a, Mode_altscr=0, Mode_irixps=1, Delay_time=1.000, Curwin=2
Def     fieldscur=AEHIoqTWKNMBcdfgjpLrsuvyzX
        winflags=129016, sortindx=19, maxtasks=0
        summclr=2, msgsclr=5, headclr=7, taskclr=7
Job     fieldscur=ABcefgjlrstuvyzMKNHIWOPQDX
        winflags=63416, sortindx=13, maxtasks=0
        summclr=6, msgsclr=6, headclr=7, taskclr=6
Mem     fieldscur=ANOPQRSTUVbcdefgjlmyzWHIKX
        winflags=65464, sortindx=13, maxtasks=0
        summclr=5, msgsclr=5, headclr=4, taskclr=5
Usr     fieldscur=ABDECGfhijlopqrstuvyzMKNWX
        winflags=65464, sortindx=12, maxtasks=0
        summclr=3, msgsclr=3, headclr=2, taskclr=7
_AATOPRC
)


ahave lynx && [[ ! -f $HOME/.lynxrc ]] && (
cat >$HOME/.lynxrc <<_AALYNXRC
accept_all_cookies=on
cookie_file=$HOME/.lynx_cookies
bookmark_file=$HOME/.lynx_bookmarks
case_sensitive_searching=off
character_set=Western (ISO-8859-1)
dir_list_order=ORDER_BY_NAME
dir_list_style=MIXED_STYLE
emacs_keys=off
file_editor=$EDITOR
file_sorting_method=BY_FILENAME
keypad_mode=LINKS_ARE_NOT_NUMBERED
lineedit_mode=Default Binding
preferred_language=en
select_popups=on
show_color=default
show_cursor=on
show_dotfiles=on
sub_bookmarks=OFF
user_mode=NOVICE
verbose_images=off
vi_keys=off
visited_links=LAST_REVERSED
STARTFILE:http://www.askapache.com/
HELPFILE:http://lynx.isc.org/release/lynx2-8-6/lynx_help/lynx_help_main.html
HELPFILE:http://lynx.isc.org/lynx2.8.7/lynx2-8-7/lynx_help/lynx_help_main.html
DEFAULT_INDEX_FILE:http://www.askapache.com/
_AALYNXRC
export LYNX_CFG=$HOME/.lynxrc
)


ahave ncftp && [[ ! -d $HOME/.ncftp || ! -f $HOME/.ncftp/bookmarks ]] && (
mkdir $HOME/.ncftp
cat >$HOME/.ncftp/bookmarks <<_AANCFTPBOOKMARKS
NcFTP bookmark-file version: 8
Number of bookmarks: ??
GNU,ftp.gnu.org,,,,,I,0,1259026516,1,1,1,1,140.186.70.20,,,,,,S,-1,
ncsa,ftp.ncsa.uiuc.edu,,,,Web,I,21,285960729237,1,1,1,1,141.142.2.14,,,,,,S,-1,
ArchLinux FTP,ftp.archlinux.org,,,,,I,21,1259026553,1,1,1,1,209.85.41.143,,,,,,S,-1,
Mozilla,ftp.mozilla.org,,,,,I,21,1259026675,1,1,1,1,63.245.208.138,,,,,,S,-1,
_AANCFTPBOOKMARKS
)


ahave wget && [[ ! -f $HOME/.wgetrc ]] && (
cat >$HOME/.wgetrc <<_AAWGETRC
header = Accept-Language: en-us,en;q=0.5
header = Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
header = Accept-Encoding: gzip,deflate
header = Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
header = Keep-Alive: 300
user_agent = Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.1.3) Gecko/20090824 Firefox/3.5.3
referer = http://www.google.com
robots = off
_AAWGETRC
)


ahave vim && [[ ! -f $HOME/.vimrc ]] && (
cat > $HOME/.vimrc <<_AAVIMRC
set showmatch
set nocompatible backspace=indent,eol,start autoindent ts=4 textwidth=0 backupcopy=yes history=500 ruler so=5 cmdheight=2 hh=20 wh=65 hlsearch ic nofoldenable t_Co=256 t_Sf=m t_Sb=m bg=dark showcmd incsearch

let $PAGER=''
syntax on
let use_xhtml = 1
let html_use_css = 1

if has("autocmd")
  if has("filetype")
    filetype on
    filetype plugin on
    filetype indent on
    set fileformats=unix,dos,mac
  endif

  au BufRead,BufNewFile * setfiletype sh
  autocmd FileType html set isk+=:,/,~
  autocmd FileType *             set shiftwidth=4
  autocmd FileType xml,html      set shiftwidth=2
  autocmd FileType java,c,cc,cpp set nocindent
  autocmd FileType text setlocal textwidth=78    " For all text files set 'textwidth' to 78 characters.

  augroup ApacheModule
    au BufRead,BufNewFile httpd*.conf*,srm.conf*,access.conf*,apache.conf*,apache2.conf*,.htaccess,.htpasswd setfiletype apache
    autocmd BufReadPost mod_*.c set ts=4
    autocmd BufReadPost mod_*.c set sw=4
  augroup END

  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("\$") |
    \   exe "normal g\`\"" |
    \ endif
  augroup END
endif

if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

_AAVIMRC
)



asetup_colors
aa_prompt
asetup_history
#[[ "$ISINCLUDED" == "no" ]] && 
export PROMPT_COMMAND='echo -ne "\033]0;$USER@$HOSTNAME  +$SHLVL @${SSH_TTY/\/dev\/} - `uptime1` \007";(( $HISTCMD % 10 == 0 )) && aa_prompt'



# temp hack for being able to source all the functions in this file from a script
[[ $- == *i* ]] && (
  export PROMPT_C=$( echo -ne "\033]0;$USER@$HOSTNAME  +$SHLVL @${SSH_TTY/\/dev\/} - `uptime1` \007" );
  echo $PROMPT_C
  
  export PROMPT_COMMAND='echo -ne "\033]0;$USER@$HOSTNAME  +$SHLVL @${SSH_TTY/\/dev\/} - `uptime1` \007";(( $HISTCMD % 10 == 0 )) && aa_prompt'
  ascript_title 1 8
  #aa_motd
  #ahave pstree && command pstree -A -u | uniq
  #aa_weather
  
  echo; pm "Functions"; aa_functions; echo; echo; pm "Aliases"; aa_aliases; echo;

  aa_calendar
  
  aa_fortune
  ahave tput && tput cup 99 0;
  
  (exit $?); exit $?
) || ( echo; pm "Functions"; aa_functions; echo; echo; pm "Aliases"; aa_aliases; echo; )























BETA=no; [[ "$BETA" == "yes" ]] && (

# ( cd /dev; ln -sf /proc/self/fd /dev/fd; ln -sf fd/0 /dev/stdin; ln -sf fd/1 /dev/stdout; ln -sf fd/2 /dev/stderr )

fix_bad_perms()
{
  find ${1:-.} -type d ! -perm 751 -exec chmod 751 {} \; 2>$N6
  find ${1:-.} -type f ! -perm 640 -exec chmod 640 {} \; 2>$N6
}


function aa_flash_screen() { echo -e "\E[?5h$<100/>\E[?5l"; }


function aa_terminfo()
{
  ahave infocmp && infocmp  -I -q && infocmp  -I -q -L
  ahave stty && stty -a
}



#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_apt_build - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_apt_build()
{ aptitude search $1; sleep 4; apt-get -u -V build-dep $1 && apt-get -u -V -b source $1; }

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# aa_aptb - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function aa_aptb()
{
    aptitude search $@
    aptitude show $@
    cont
    apt-get -u -V build-dep $@ && apt-get -u -V -b source $@ || apt-get -u -V --reinstall install $@
}





#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# h1 - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function h1()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME query" >&2 && return 2
  command grep -h -i "$@" $HISTFILEMASTER
}

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# h1c - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function h1c()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME query" >&2 && return 2
  command grep --color=always -h -i "$@" $HISTFILEMASTER
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# hpopular - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function hpopular()
{
  cat $HISTFILEMASTER | awk '{print $2}' | sort | uniq -c | sort -rn | head -n ${1:-50};
}

#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# centerit - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function centerit() 
{ echo "$@" | awk '
{ spaces = ('$COLUMNS' - length) / 2
  while (spaces-- > 0) printf (" ")
  print
}'
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# tac1  - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function tac1()
{
  [[ "$#" -gt "0" && $1 == *-h* ]] && ahelp $1 && echo "Usage: $FUNCNAME" && return 2
  [[ $# -eq 0 ]] && exec sed -n '{ 1! G; $ p; h; }' || sed -n '{ 1! G; $ p; h; }' $@
}


#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# quote - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function quote()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  echo \'${1//\'/\'\\\'\'}\';
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# dequote - Function 
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function dequote()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  eval echo "$1";
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# get_pids_on_system - Function to show pids on system
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function get_pids_on_system()
{
  command ps axo pid|sed 1d;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# get_pgids_on_system - Function to show pgids on system
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function get_pgids_on_system()
{
  command ps axo pgid|sed 1d;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# get_users_on_system - Function that uses the getent program to display all users on system
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function get_users_on_system()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  ahave getent &>$N6 && getent passwd|awk -F: '{print $1}' && return; awk 'BEGIN {FS=":"} {print $1}' /etc/passwd;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# get_groups_on_system - Function that uses the getent program to display all groups on system
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function get_groups_on_system()
{
  [[ "$#" -lt "1" ]] && echo "Usage: $FUNCNAME " >&2 && return 2
  ahave getent &>$N6 && getent group|awk -F: '{print $1}' && return; awk 'BEGIN {FS=":"} {print $1}' /etc/group;
}






#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
# mp3info - Function that uses ffmpeg to display information for mp3files in the current directory
#--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--=--#
function mp3info()
{
  ahave ffmpeg || return;
  ls *.mp3 |xargs -ix 2>&1 ffmpeg -i x|grep -v "^Must" |grep -v "built\|libavutil\|libavcodec\|configuration\|FFmpeg\|libavformat";
}

find_execs(){ file *| grep "shell\|executable"|sed -e 's/:.*$//g'; }





### END BETA FUNCTIONS
)














#       gzip [ -acdfhlLnNrtvV19 ] [-S suffix] [ name ...  ]
#       gunzip [ -acfhlLnNrtvV ] [-S suffix] [ name ...  ]
#       zcat [ -fhLV ] [ name ...  ]
#
#       gunzip  takes a list of files on its command line and replaces each file whose name ends with .gz, -gz, .z, -z, _z or .Z and which begins with the correct magic number with an uncompressed
#       file without the original extension.  gunzip also recognizes the special extensions .tgz and .taz as shorthands for .tar.gz and .tar.Z respectively.  When compressing, gzip uses  the  .tgz
#       extension if necessary instead of truncating a file with a .tar extension.
#
#       zcat  is identical to gunzip -c.  (On some systems, zcat may be installed as gzcat to preserve the original link to compress.)  zcat uncompresses either a list of files on the command line
#       or its standard input and writes the uncompressed data on standard output.  zcat will uncompress files that have the correct magic number whether they have a .gz suffix or not.
#       -l --list
#              The uncompressed size is given as -1 for files not in gzip format, such as compressed .Z files. To get the uncompressed size for such a file, you can use:
#                  zcat file.Z | wc -c
#
#              The compression methods currently supported are deflate, compress, lzh (SCO compress -H) and pack.  The crc is given as ffffffff for a file not in gzip format.
#              With --verbose, the size totals and compression ratio for all files is also displayed, unless some sizes are unknown. With --quiet, the title and totals lines are not displayed.
#       -r --recursive
#              Travel the directory structure recursively. If any of the file names specified on the command line are directories, gzip will descend into the directory and compress all  the  files
#              it finds there (or decompress them in the case of gunzip ).
#       If you want to recompress concatenated files to get better compression, do:
#             gzip -cd old.gz | gzip > new.gz

#       If a compressed file consists of several members, the uncompressed size and CRC reported by the --list option applies to the last member only. If you need the  uncompressed  size  for  all
#       members, you can use:
#             gzip -cd file.gz | wc -c






#   Note that the order of redirections is significant. For example, the command
#   ls > dirlist 2>&1
#   directs both standard output and standard error to the file dirlist, while the command
#
#   ls 2>&1 > dirlist
#   directs only the standard output to file dirlist, because the standard error was duplicated as standard output before the standard output was redirected to dirlist.




##################################################################################################################################################################################
# personalized colors
##################################################################################################################################################################################
# Attribute codes:    00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:   30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes: 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
# NORMAL 00       # global default, although everything should be something.
# FILE 00         # normal file
# DIR 01;34       # directory
# LINK 01;36      # symbolic link.
# FIFO 40;33      # pipe
# SOCK 01;35      # socket
# DOOR 01;35      # door
# BLK 40;33;01    # block device driver
# CHR 40;33;01    # character device driver
# ORPHAN 40;31;01 # symlink to nonexistent file
# EXEC 01;32      # executables
##################################################################################################################################################################################



# Advanced Shell Limits
##################################################################################################################################################################################
# -S      use the `soft' resource limit
# -H      use the `hard' resource limit
# -a      all current limits are reported
# -c      the maximum size of core files created
# -d      the maximum size of a process's data segment
# -f      the maximum size of files created by the shell
# -l      the maximum size a process may lock into memory
# -m      the maximum resident set size
# -n      the maximum number of open file descriptors
# -p      the pipe buffer size
# -s      the maximum stack size
# -t      the maximum amount of cpu time in seconds
# -u      the maximum number of user processes
# -v      the size of v
# [see man getrlimit, help ulimit]
##################################################################################################################################################################################
##################################################################################################################################################################################
# Trapping Signals to Catch Errors
##################################################################################################################################################################################
# The first digit selects the set user ID (4) and set group ID (2) and sticky (1) attributes.
# The second digit selects permissions for the user who owns the file: read (4), write (2), and execute (1)
# The third selects permissions for other users in the file's group, with the same values
# The fourth for other users not in the file's group, with the same values.
# [see man chmod, help umask]
##################################################################################################################################################################################
##################################################################################################################################################################################
# 1      2      3       4      5       6       7      8      9       10      11      12      13      14      15      17      18      19      20      21
# SIGHUP SIGINT SIGQUIT SIGILL SIGTRAP SIGABRT SIGBUS SIGFPE SIGKILL SIGUSR1 SIGSEGV SIGUSR2 SIGPIPE SIGALRM SIGTERM SIGCHLD SIGCONT SIGSTOP SIGTSTP SIGTTIN 
# [see man bash, man signal, help trap]
##################################################################################################################################################################################



# http://tldp.org/LDP/abs/html/sample-bashrc.html
##################################################################################################################################################################################
# e [errexit]     Exit immediately if a command exits with a non-zero status.
# B [braceexpand] The shell will perform brace expansion.
# h [hashall]     Remember the location of commands as they
# f [noglob]      Disable file name generation (globbing).
# H [histexpand]  Enable ! style history substitution.
# v [verbose]     Print shell input lines as they are read.
# x [xtrace]      Print commands and their arguments as they are executed.
# n [noexec]      Read commands but do not execute them.
#   [history]       Enable command history
##################################################################################################################################################################################


##################################################################################################################################################################################
# [see man bash, help set]
# cdable_vars   an argument to the cd builtin command that is not a directory is assumed to be the name of a variable dir to change to.
# cdspell     minor errors in the spelling of a directory component in a cd command will be corrected.  
# checkhash     bash checks that a command found in the hash table exists before execute it.  If no longer exists, a path search is performed.
# checkwinsize    bash checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS.
# cmdhist     bash attempts to save all lines of a multiple-line command in the same history entry.  Allows re-editing of multi-line commands.
# dotglob     bash includes filenames beginning with a `.' in the results of pathname expansion.
# execfail      a non-int shell will not exit if it cannot execute the file specified as an argument to the exec builtin command, like int sh.
# expand_aliases  aliases are expanded as described above under ALIASES.  This option is enabled by default for interactive shells.
# extglob       the extended pattern matching features described above under Pathname Expansion are enabled.
# histappend    the history list is appended to the file named by the value of the HISTFILE variable when shell exits, no overwriting the file.
# hostcomplete    and readline is being used, bash will attempt to perform hostname completion when a word containing a @ is being completed
# huponexit     bash will send SIGHUP to all jobs when an interactive login shell exits.
# interactive_comments    allow a word beginning with # to cause that word and all remaining characters on that line to be ignored in an interactive shell
# lithist       if cmdhist option is enabled, multi-line commands are saved to the history with embedded newlines rather than using semicolon
# login_shell     shell sets this option if it is started as a login shell (see INVOCATION above).  The value may not be changed.
# mailwarn        file that bash is checking for mail has been accessed since the last checked, ``The mail in mailfile has been read'' is displayed.
# no_empty_cmd_completion bash will not attempt to search the PATH for possible completions when completion is attempted on an empty line.
# nocaseglob    bash matches filenames in a case-insensitive fashion when performing pathname expansion (see Pathname Expansion above).
# nullglob      bash allows patterns which match no files (see Pathname Expansion above) to expand to a null string, rather than themselves.
# progcomp      the programmable completion facilities (see Programmable Completion above) are enabled.  This option is enabled by default.
# promptvars    prompt strings undergo variable and parameter expansion after being expanded as described in PROMPTING above.  
# shift_verbose   the shift builtin prints an error message when the shift count exceeds the number of positional parameters.
# sourcepath    the source (.) builtin uses the value of PATH to find the directory containing the file supplied as an argument.
# xpg_echo      the echo builtin expands backslash-escape sequences by default.
# [see man bash, help shopt]
##################################################################################################################################################################################

##################################################################################################################################################################################
# \a     an ASCII bell character (07)
# \d     the date in "Weekday Month Date" format (e.g., "Tue May 26")
# \D{format}  the format is passed to strftime(3) and the result is inserted into the prompt string;
# \e     an ASCII escape character (033)
# \h     the hostname up to the first `.'
# \H     the hostname
# \j     the number of jobs currently managed by the shell
# \l     the basename of the shell's terminal device name
# \n     newline
# \r     carriage return
# \s     the name of the shell, the basename of $0 (the portion following the final slash)
# \t     the current time in 24-hour HH:MM:SS format
# \T     the current time in 12-hour HH:MM:SS format
# \@     the current time in 12-hour am/pm format
# \A     the current time in 24-hour HH:MM format
# \u     the username of the current user
# \v     the version of bash (e.g., 2.00)
# \V     the release of bash, version + patchelvel (e.g., 2.00.0)
# \w     the current working directory
# \W     the basename of the current working directory
# \!     the history number of this command
# \#     the command number of this command
# \$     if the effective UID is 0, a #, otherwise a $
# \nnn   the character corresponding to the octal number nnn
# \\     a backslash
# \[     begin a sequence of non-printing characters, which could be used to embed a terminal control sequence into the prompt
# \]     end a sequence of non-printing characters
##################################################################################################################################################################################


##################################################################################################################################################################################
# HISTCONTROL
#    If  set  to a value of ignorespace, lines which begin with a space character are not entered on the history list.  
#    If set to a value of ignoredups, lines matching the last history line are not entered.  A value of ignoreboth combines the two options.
#    If unset, or if set to any other value than those above, all lines read by the parser are saved on the history list, subject to the value of HISTIGNORE.  
# HISTFILE
#    The name of the file in which command history is saved (see HISTORY below).  The default value is ~/.bash_history.  If unset, the command history is not saved when an interactive shell exits.
# HISTFILESIZE
#    The  maximum number of lines contained in the history file.  When this variable is assigned a value, the history file is truncated, if necessary, to contain no more than that number of lines.  
#    The default value is 500.  The history file is also trun-cated to this size after writing it when an interactive shell exits.
# HISTIGNORE
#    A colon-separated list of patterns used to decide which command lines should be saved on the history list.  Each pattern is anchored at the beginning of the line and must match the complete line (no implicit `*' is appended).
#    Each pattern is  tested against  the  line  after  the  checks  specified  by HISTCONTROL are applied.  In addition to the normal shell pattern matching characters, `&' matches the previous history line.  
#    `&' may be escaped using a backslash; the backslash is removed before attempting a match.  The second and subsequent lines of a multi-line compound command are not tested, and are added to the history regardless of the value of HISTIGNORE.
# HISTSIZE
#    The number of commands to remember in the command history (see HISTORY below).  The default value is 500.
#
##################################################################################################################################################################################



############################################################################################################################################################
# bash defines the following built-in commands: 
#   :, ., [, alias, bg, bind, break, builtin, case, cd, command, compgen, complete, continue, declare, dirs
#   disown, echo, enable, eval, exec, exit, export, fc, fg, getopts, hash, help, history, if, jobs, kill,
#   let, local, logout, popd, printf, pushd, pwd, read, readonly, return, set, shift, shopt, source, suspend
#   test, times, trap, type, typeset, ulimit, umask, unalias, unset, until, wait, while



# Connectives for `test'
# ! EXPR  -  True if EXPR is false.
# EXPR1 -a EXPR2  -  True if both EXPR1 and EXPR2 are true.
# EXPR1 -o EXPR2  -  True if either EXPR1 or EXPR2 is true.

# File type tests
# -b FILE  -  True if FILE exists and is a block special device.
# -c FILE  -  True if FILE exists and is a character special device.
# -d FILE  -  True if FILE exists and is a directory.
# -f FILE  -  True if FILE exists and is a regular file.
# -L FILE  -  True if FILE exists and is a symbolic link.
# -p FILE  -  True if FILE exists and is a named pipe.
# -S FILE  -  True if FILE exists and is a socket.
# -t FD  -  True if FD is a file descriptor that is associated with a terminal.

# Access permission tests
# -g FILE  -  True if FILE exists and has its set-group-id bit set.
# -k FILE  -  True if FILE has its "sticky" bit set.
# -r FILE  -  True if FILE exists and is readable.
# -u FILE  -  True if FILE exists and has its set-user-id bit set.
# -w FILE  -  True if FILE exists and is writable.
# -x FILE  -  True if FILE exists and is executable.
# -O FILE  -  True if FILE exists and is owned by the current effective user id.
# -G FILE  -  True if FILE exists and is owned by the current effective group id.

# File characteristic tests
# -e FILE  -  True if FILE exists.
# -s FILE  -  True if FILE exists and has a size greater than zero.
# FILE1 -nt FILE2  -  True if FILE1 is newer (according to modification date) than FILE2, or if FILE1 exists and FILE2 does not.
# FILE1 -ot FILE2  -  True if FILE1 is older (according to modification date) than FILE2, or if FILE2 exists and FILE1 does not.
# FILE1 -ef FILE2  -  True if FILE1 and FILE2 have the same device and inode numbers,  i.e., if they are hard links to each other.

# String tests
# -z STRING  -  True if the length of STRING is zero.
# -n STRING
# STRING  -  True if the length of STRING is nonzero.
# STRING1 = STRING2  -  True if the strings are equal.
# STRING1 != STRING2  -  True if the strings are not equal.

# Numeric tests
# ARG1 -eq ARG2
# ARG1 -ne ARG2
# ARG1 -lt ARG2
# ARG1 -le ARG2
# ARG1 -gt ARG2
# ARG1 -ge ARG2
############################################################################################################################################################



############################################################################################################################################################
# Optional Software that is awesome
#
# ftp://ftp.gnu.org/pub/gnu/gawk/gawk-3.1.7.tar.gz
# ftp://alpha.gnu.org/pub/gnu/libidn/libidn-1.9.tar.gz
# ftp://ftp.berlios.de/pub/smake/alpha/smake-1.2a45.tar.gz
# ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-7.9.tar.gz
# ftp://ftp.gnu.org/gnu/gdb/gdb-7.0.tar.bz2
# ftp://ftp.gnu.org/gnu/gmp/gmp-4.3.1.tar.gz
# ftp://ftp.gnu.org/pub/gnu/autoconf/autoconf-2.64.tar.gz
# ftp://ftp.gnu.org/pub/gnu/automake/automake-1.11.tar.gz
# ftp://ftp.gnu.org/pub/gnu/bash/bash-4.0.tar.gz
# ftp://ftp.gnu.org/pub/gnu/bash/bash-doc-3.2.tar.gz
# ftp://ftp.gnu.org/pub/gnu/bash/bashref.texi.gz
# ftp://ftp.gnu.org/pub/gnu/bash/readline-5.1.tar.gz
# ftp://ftp.gnu.org/pub/gnu/binutils/binutils-2.19.tar.gz
# ftp://ftp.gnu.org/pub/gnu/bison/bison-2.4.tar.gz
# ftp://ftp.gnu.org/pub/gnu/findutils/findutils-4.4.2.tar.gz
# ftp://ftp.gnu.org/pub/gnu/fontutils/fontutils-0.7.tar.gz
# ftp://ftp.gnu.org/pub/gnu/g77/g77-0.5.23.tar.gz
# ftp://ftp.gnu.org/pub/gnu/gcc/gcc-4.4.2/gcc-4.4.2.tar.gz
# ftp://ftp.gnu.org/pub/gnu/gnutls/gnutls-2.8.4.tar.bz2
# ftp://ftp.gnu.org/pub/gnu/grep/grep-2.5.4.tar.gz
# ftp://ftp.gnu.org/pub/gnu/groff/groff-1.20.tar.gz
# ftp://ftp.gnu.org/pub/gnu/gzip/gzip-1.3.9.tar.gz
# ftp://ftp.gnu.org/pub/gnu/less/less-418.tar.gz
# ftp://ftp.gnu.org/pub/gnu/m4/m4-1.4.13.tar.gz
# ftp://ftp.gnu.org/pub/gnu/make/make-3.81.tar.gz
# ftp://ftp.gnu.org/pub/gnu/nano/nano-2.1.9.tar.gz
# ftp://ftp.gnu.org/pub/gnu/readline/readline-6.0.tar.gz
# ftp://ftp.gnu.org/pub/gnu/screen/screen-4.0.3.tar.gz
# ftp://ftp.gnu.org/pub/gnu/sed/sed-4.2.1.tar.gz
# ftp://ftp.gnu.org/pub/gnu/tar/cpio-2.8.tar.gz
# ftp://ftp.gnu.org/pub/gnu/tar/tar-1.22.tar.gz
# ftp://ftp.gnu.org/pub/gnu/termcap/termcap-1.3.tar.gz
# ftp://ftp.gnu.org/pub/gnu/termutils/termutils-2.0.tar.gz
# ftp://ftp.gnu.org/pub/gnu/wget/wget-1.12.tar.gz
# ftp://ftp.gnu.org/pub/gnu/which/which-2.20.tar.gz
# ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
# ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.1.tar.bz2
# ftp://xmlsoft.org/libxml2/libxml2-2.7.6.tar.gz
# ftp://xmlsoft.org/libxml2/libxslt-1.1.26.tar.gz
# http://c-ares.haxx.se/c-ares-1.6.0.tar.gz
# http://curl.haxx.se/download/curl-7.19.4.tar.gz
# http://download.oracle.com/berkeley-db/db-4.7.25.tar.gz
# http://downloads.sourceforge.net/libpng/libpng-1.2.40.tar.gz
# http://downloads.sourceforge.net/sourceforge/docutils/docutils-0.5.tar.gz
# http://downloads.sourceforge.net/sourceforge/freetype/freetype-2.3.11.tar.gz
# http://downloads.sourceforge.net/sourceforge/ghostscript/ghostscript-8.70.tar.bz2
# http://downloads.sourceforge.net/sourceforge/mcrypt/mcrypt-2.6.8.tar.gz
# http://downloads.sourceforge.net/sourceforge/mhash/mhash-0.9.9.9.tar.gz
# http://downloads.sourceforge.net/sourceforge/strace/strace-4.5.18.tar.bz2
# http://lynx.isc.org/current/lynx2.8.8dev.1.tar.gz
# http://mirrors.kernel.org/gnu/libiconv/libiconv-1.13.1.tar.gz
# http://oss.itsystementwicklung.de/download/pysqlite/2.5/2.5.5/pysqlite-2.5.5.tar.gz
# http://php.net/distributions/php-5.3.0.tar.gz
# http://pypi.python.org/packages/2.6/s/setuptools/setuptools-0.6c9-py2.6.egg
# http://pypi.python.org/packages/source/s/setuptools/setuptools-0.6c9.tar.gz
# http://www.bzip.org/1.0.5/bzip2-1.0.5.tar.gz
# http://www.dillo.org/download/dillo-2.1.1.tar.bz2
# http://www.ijg.org/files/jpegsrc.v7.tar.gz
# http://www.libgd.org/releases/gd-2.0.35.tar.gz
# http://www.lua.org/ftp/lua-5.1.4.tar.gz
# http://www.lzop.org/download/lzop-1.02rc1.tar.gz
# http://www.mavetju.org/download/dnstracer-1.9.tar.gz
# http://www.oberhumer.com/opensource/lzo/download/lzo-2.03.tar.gz
# http://www.oberhumer.com/opensource/lzo/download/minilzo-2.03.tar.gz
# http://www.python.org/ftp/python/2.6.3/Python-2.6.3.tgz
# http://www.python.org/ftp/python/3.1.1/Python-3.1.1.tgz
# http://www.sqlite.org/sqlite-3.6.12.tar.gz
# http://www.zlib.net/zlib-1.2.3.tar.gz
# 
############################################################################################################################################################



# Local Variables:
# mode:shell-script
# sh-shell:bash
# End:

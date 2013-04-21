#!/bin/echo 'Please, do not execute this file, only source.'
# /etc/vanilla-svr.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

#-----------------------------------------------------------------------------
# shopt options
#-----------------------------------------------------------------------------
# If set, minor errors in the spelling of a directory component in a cd 
# command will be corrected.
shopt -s cdspell 

# If set, Bash checks the window size after each command and, if
# necessary, updates the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, and Readline is being used, Bash will not attempt to search the 
# PATH for possible completions when completion is attempted on 
# an empty line.
shopt -s no_empty_cmd_completion

# If set, a command name that is the name of a directory is executed
# as if it were the argument to the cd command. This option is only
# used by interactive shells.
shopt -s autocd

# If set, Bash includes filenames beginning with a ‘.’ in the results of
# filename expansion.
shopt -s dotglob

# If set, the extended pattern matching features described above (see
# Section 3.5.8.1 [Pattern Matching], page 24) are enabled.
shopt -s extglob

# If set, the history list is appended to the file named by the value of
# the HISTFILE variable when the shell exits, rather than overwriting
# the file.
shopt -s histappend

# If set, Bash attempts to save all lines of a multiple-line command
# in the same history entry. This allows easy re-editing of multi-line
# commands.
shopt -s cmdhist

# If set, and Readline is being used, Bash will attempt to perform
# hostname completion when a word containing a ‘@’ is being completed 
# (see Section 8.4.6 [Commands For Completion], page 110).
# This option is enabled by default.
shopt -s hostcomplete

# If set, Bash attempts spelling correction on directory names during
# word completion if the directory name initially supplied does not
# exist.
shopt -s dirspell

# If set, patterns which fail to match filenames during filename expansion
# result in an expansion error
shopt -s lithist


# Change the window title of X terminals 
case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
esac
# set a fancy prompt (non-color, unless we know we "want" color)
case "${TERM}" in
    xterm-256color|xterm-color|gnome) color_prompt=yes;;
esac
#use_color=false

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

# if [[ "${color_prompt}" = "yes" ]] ; then
#     # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
#     if type -P dircolors >/dev/null ; then
#         if [[ -f ~/.dir_colors ]] ; then
#             eval $(dircolors -b ~/.dir_colors)
#         elif [[ -f /etc/DIR_COLORS ]] ; then
#             eval $(dircolors -b /etc/DIR_COLORS)
#         fi
# fi
#-----------------------------------------------------------------------------
# Generic functions
#-----------------------------------------------------------------------------
_upper_to_lower()
{
"$@"|tr '[:upper:]' '[:lower:]'
}

_lower_to_upper()
{
"$@"|tr '[:lower:]' '[:upper:]'
}

#-----------------------------------------------------------------------------
# OS-specific Actions
#-----------------------------------------------------------------------------
if [[ -x /usr/gnu/bin/uname ]]; then
    ## Solaris and variants may be using `/usr/gnu/bin/uname`
    uname_cmd=/usr/gnu/bin/uname

    ## Normal GNU/Linux distros will use `/bin/uname`
    elif [[ -x /bin/uname ]]; then
        uname_cmd=/bin/uname
    else uname_cmd=$(which uname)
fi

if [[ -f /opt/custom/is_smartos ]]; then
    OS_type=smartos
    else
    OS_type=$(_upper_to_lower ${uname_cmd} -o)
fi


case "${OS_type}" in
    "smartos")
        export TZ="US/Pacific"
        ;;

    "solaris")
        ## Solaris 11 seems to have partial support for xterm-256color
        ## as such, we will force xterm-color instead
        is_oracle=''
        is_oracle=$(_upper_to_lower cat /etc/release|head -1|sed -e 's/^  *//g'|cut -d' ' -f1)

        ## Add all Solaris and variant aliases here
        alias acl_ls='/usr/bin/ls'
        alias acl_chmod='/usr/bin/chmod'

        ## Test to see if `/usr/bin/gnu` is in the path, if not, add it
        gnu_inpath=N
        for iter in $(echo $PATH|tr ':' ' '); do 
            [[ $iter = '/usr/gnu/bin' ]] && gnu_inpath=Y
        done

        ## If `/usr/gnu/bin` is present, and not already in the path,
        ## we need to make sure to prepend it to existing $PATH env. variable
        if [[ -d /usr/gnu/bin && ${gnu_inpath} = 'N' ]]; then
            export PATH=~/bin:/usr/gnu/bin:$PATH
        else
            export PATH=~/bin:$PATH
        fi
        unset gnu_inpath
        ;;

    "gnu/linux")
        grep_cmd=$(which grep)
        OS_dist=$(_upper_to_lower sed -n '1p' /etc/issue|cut -d' ' -f1)
        case "${OS_dist}" in
            "centos") export DISTRO=centos
                ;;
            "ubuntu") export DISTRO=ubuntu 
                ;;
            *) ## Do something if anything else
                printf "%s\n" "Your operating system is not known!"
                ;;
        esac

        ;;
esac

#-----------------------------------------------------------------------------
# Check for 256-color terminal and export TERM
#-----------------------------------------------------------------------------
## Build array of expected terminal types from most to least preferred
TERM_TYPE=(
xterm-256color
gnome-256color
xterm-color
xterm
gnome
)

## Walk through array of terminal types TERM_TYPE and settle on one
## of the types, hopefully one of first two
for term in "${TERM_TYPE[@]}"; do
    ## If OS is oracle, due to Solaris 10's and 11's partial xterm-256color
    ## support, let's not use it
    if [[ ${is_oracle} = 'oracle' ]]; then
        export TERM=xterm-color
        unset is_oracle
        break
    fi
    if [[ $(tput -T "$term" colors 2>/dev/null) ]]; then
        echo "Setting TERM environment variable to $term"
        export TERM="$term"
        break
    fi
done

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Set options for less
export LESS="-MJWi --tabs=4 --shift 5"
export LESSHISTFILE="${HOME}/.less_history_${HOSTNAME}"
alias less="less -R"

if [[ "$UID" != 0 ]]; then
    export LESSCHARSET="utf-8"
    if [[ -z "$LESSOPEN" ]]; then
        if [[ "$__distribution" = "Debian" ]]; then
            [[ -x $(which lesspipe.sh 2> /dev/null) ]] && eval "$(lesspipe)"
        else
            [[ -x $(which lesspipe.sh 2> /dev/null) ]] && export LESSOPEN="|lesspipe.sh %s"
        fi
    fi
    # Yep, 'less' can colorize manpages
    export LESS_TERMCAP_mb=$'\E[01;31m'
    export LESS_TERMCAP_md=$'\E[01;31m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[01;44;33m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[01;32m'
fi

## dotfiles path
MYDOTFILES="${HOME}/.profile.d/dotfiles"

# Screenrc environment
export SCREENRC="${MYDOTFILES}/screenrc"

# Bash History
export HISTSIZE=5000
export HISTFILESIZE=5000
export HISTFILE="${HOME}/.bash_history_${HOSTNAME}"
if [ "$UID" != 0 ]; then
    export HISTCONTROL="ignoreboth"   # ignores duplicate lines next to each other and lines with a leading space
    export HISTIGNORE="[bf]g:exit:logout"
fi

#-----------------------------------------------------------------------------
# Begin Prompt section
#-----------------------------------------------------------------------------
export GT_RESET="$(tput sgr0)"      # Reset all attributes
export GT_BRIGHT="$(tput bold)"     # Set "bright" attribute
export GT_DIM="$(tput dim)"         # Set "dim" attribute
export PALE_ROSE="$(tput setaf 173)"
export BRIGHT_BLUE="$(tput setaf 39)"
export PALE_BLUE="$(tput setaf 153)"
export BRIGHT_YELLOW="$(tput setaf 220)"
export PALE_GREEN="$(tput setaf 156)"
export SOFT_PINK="$(tput setaf 167)"
export BRIGHT_RED="$(tput setaf 196)"

# Stores the exit status of the last command for use by show_exit_status function.
if [[ ! $PROMPT_COMMAND =~ store_exit_status ]]; then
  export PROMPT_COMMAND="store_exit_status && ${PROMPT_COMMAND:-:}"
fi

store_exit_status() {
  LAST_EXIT_STATUS=$?
}

show_time() {
  echo "${PALE_BLUE}[$(date +%H:%M)]${GT_RESET}"
}

show_exit_status() {
  if [ "x${LAST_EXIT_STATUS}" != "x0" ]; then
    echo "${GT_BRIGHT}${SOFT_PINK}[${LAST_EXIT_STATUS}]${GT_RESET}"
  fi
}

prompt_color() {

if [[ -z "$SSH_CLIENT" && "${UID}" -ne "0" ]]; then
        echo "${GT_BRIGHT}${PALE_GREEN}"
    elif [ "${UID}" -eq "0" ]; then
        echo "${GT_BRIGHT}${BRIGHT_RED}"
    else
        echo "${GT_BRIGHT}${BRIGHT_YELLOW}"
fi
}

prompt_symbol() {
if [ "${UID}" -eq "0" ]; then
        printf "[root]⌘ "
    else
        printf "⌘ "
fi

}

#-----------------------------------------------------------------------------
# Prompts - defined colors below
#-----------------------------------------------------------------------------
set_prompts() {

# Define prompt based on whether I am local or connected via ssh

        PS1='$(show_time) $(prompt_color)'"\h${COLOR_NONE}:${BRIGHT_BLUE}\w${GT_RESET}"' $(show_exit_status)'"${GT_RESET}\n$(prompt_symbol) "
   
        PS2="${BRIGHT_BLUE}>${DEFAULT} "
        PS3=$PS2
        PS4="${BRIGHT_RED}+${DEFAULT} "

    # Special prompt for Debian: Include variable identifying the chroot you work in in the prompt
    # (copied from default Debian .bashrc file, never actually tested)
    if [ -z "$debian_chroot" ] && [ -r "/etc/debian_chroot" ]; then
        export debian_chroot=`cat /etc/debian_chroot`
        PS1="${debian_chroot:+($debian_chroot)}${PS1}"
    fi

    export PS1 PS2 PS3 PS4
}
set_prompts
unset -f set_prompts

#-----------------------------------------------------------------------------
# Key aliases
#-----------------------------------------------------------------------------
alias refresh='. ~/.bashrc'
alias s='sudo'
# if [[ $(_upper_to_lower uname -o) =~ solaris ]]; then 

#  fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable bash completion
if [[ -f ~/.bash_completion ]]; then 
    .  ~/.bash_completion
elif [[ -f /etc/bash/bash_completion ]]; then
    . /etc/bash/bash_completion
fi

#-----------------------------------------------------------------------------
# Proxy/Tunneling Settings
#-----------------------------------------------------------------------------
if [[ ! -f ~/noproxy ]]; then 
    export http_proxy="http://10.10.100.5:3128/"
    export https_proxy="http://10.10.100.5:3128/"
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

#-----------------------------------------------------------------------------
# Environment variables
#-----------------------------------------------------------------------------
if [[ -x /usr/bin/vim ]]; then
    export EDITOR=/usr/bin/vim
elif [[ -x /usr/bin/nano ]]; then
    export EDITOR=/usr/bin/nano
else
    printf "%s\n" "[WARN] Unable to find an editor, and export \$EDITOR variable"
fi

#-----------------------------------------------------------------------------
# Additional Customizations
#-----------------------------------------------------------------------------
if [[ -f ~/.envrc ]]; then
    . ~/.envrc
fi

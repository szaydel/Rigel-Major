#!/opt/local/gnu/bin/echo

## This is where we are going to be executing commands from. Please, do not
## make changes to this parameter, as doing so will break current configuration.

x_cmd_name='mortar'
x_cmd_path=/racktop/local/bin/fab
racktop_base=/racktop/local
mortar_base=${racktop_base}/mortar
mortar_tasks=${mortar_base}/__init__.py
mortar_rcfile=${mortar_base}/.mortarrc

## Setup the prompt to reflect some useful information, including number
## of command being called, as well as current working directory.
function set_prompt () {
    local rc=$?
    (( ${rc} == 0 )) && last_status="success" || last_status="fail"
    # PS1="cmd#: <\!> cwd: \w\n\u@\h [$?]\\$ "
    PS1="\ncmd#: <\!> previous cmd: <${last_status}>\n\u@\h [${rc}]\\$ "
    PS2="cont> "
}

function error_reply ()
{
    local cmd_name=$1
    printf "Error: %s\n" "Command ${cmd_name} not meant to be called directly. Please, use show-commands-help for help."
    return 1
}

## We do not want `fab` to be executed directly, as such we will overwrite it
## using this function.
function fab () 
{
    error_reply fab
}
if [[ "${PS1}" ]]; then
    shopt -s checkwinsize cdspell extglob histappend
    alias ll='ls -lF'
    alias ls='ls --color=auto'

    ## Set aliases required for the mortar command line.
    if [[ -f ${mortar_rcfile} ]]; then
        alias mortar='${x_cmd_path} -c ${mortar_rcfile} -f ${mortar_tasks}'
        alias mortar-list='${x_cmd_path} -c ${mortar_rcfile} -f ${mortar_tasks} --list'
    else
        alias mortar='${x_cmd_path} -f ${mortar_tasks}'
        alias mortar-list='${x_cmd_path} -f ${mortar_tasks} --list'
    fi

    HISTFILE=~/.mortar_history
    HISTSIZE=2000
    HISTFILESIZE=2000
    HISTCONTROL=ignoreboth
    HISTIGNORE="[bf]g:exit:quit"
    HISTTIMEFORMAT='%F %T '
  
  ## Enable completion for top-level commands for mortar.
  [[ -f ~/.complete ]] && . ~/.complete

  # PS1="cwd: \w\n[\u@\h <\#>]\\$ "
  if [[ -n "${SSH_CLIENT}" ]]; then
    PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%\.*} \007" && history -a && set_prompt'
  else
    PROMPT_COMMAND=set_prompt
  fi
fi

case "$TERM" in
  xterm-256color)
    export TERM=xterm-color
    ;;
  screen)
    export TERM=xterm-color
    ;;
  screen-256color)
    export TERM=xterm-color
    ;;
esac
export PATH=/racktop/local/bin:$PATH
export TZ='US/Pacific'
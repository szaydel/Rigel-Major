#!/bin/echo : "File should be sourced, not executed"
###############################################################################
# All my commonly used aliases
#
###############################################################################

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# SSH remote connectivity aliases
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
alias rsh='rsync --rsh="ssh -o ClearAllForwardings=yes" --verbose --human-readable --progress --archive --partial --compress --copy-dirlinks'

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Security and Encryption
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	if [ -x $(which ecryptfsd) ]; then # Create aliases if ecryptfs exists
		
		alias secreton='ecryptfs-mount-private'
		alias secretoff='ecryptfs-umount-private'
	fi
	
alias protect-file='openssl aes-256-cbc -a -salt -in $1 -out $1'
# alias genpass='openssl rand -base64 37 | cut -c 1-10'
alias mykey='clear; gpg2 --decrypt ~/Private/mykeys.gpg 2> /dev/null | nano --view -'
# alias adm-pass='clear; gpg2 --decrypt ~/Private/admin-passwords.file.gpg'
alias pwgen='pwgen -ncs'
alias gpg='/usr/bin/gpg2'
alias my-mount-passphrase='printf "%s1d35792c8208974cfba3996b1c1cc0bb\n" '


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Aptitude
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# If server is a Ubuntu/Debian Server - simplify package and update management
	if [ -x $(which apt-get) ]; then
		
		AP=$(which apt-get) # Variable to use in all Aptitude aliases referencing /usr/bin/apt-get
			alias install='sudo ${AP} install'
			alias remove='sudo ${AP} remove'
			alias purge='sudo ${AP} remove --purge'
			alias update='sudo ${AP} update && sudo apt-get upgrade'
			alias upgrade='sudo ${AP} upgrade'
			alias clean='sudo ${AP} autoclean && sudo apt-get autoremove'
			alias search='apt-cache search'
			alias show='apt-cache show'
			alias sources='sudo vim /etc/apt/sources.list'
			alias addkey='sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com'
			alias addppa='sudo add-apt-repository'
	fi
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
# GIT
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	if [ -x $(which git) ]; then
	
     GIT=$(which git)
        alias git-push-all='git-push-github && git-push-rubyforge'
        alias git-push-origin='git push origin master'
        alias git-push-rubyforge='git push rubyforge master'
        alias git-push-unfuddle='git push unfuddle master'
        alias git-reset='git reset --hard'
        alias git-ls='git log --pretty=oneline'
        alias git-undo='git reset --soft HEAD^'
        alias git-chkout='git checkout'
        alias git-add='git add'
        alias git-add='git add --all'
        alias git-status='git status; git submodule status'
        alias git-commit='git commit'
        alias git-commit-all='git commit --all --status'
        alias git-commit-test='git commit --status --dry-run'
        alias git-commit-nostage='git commit --all --message'       
        
alias gcam='git commit -am'
alias gcm='git commit -m'
alias gl='git pull'
alias gp='git push'
alias gsh='git show'
alias glg='git log'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff'
alias gd1='echo "git diff HEAD";  git diff HEAD'
alias gd2='echo "git diff HEAD^"; git diff HEAD^'
alias grmall="gs | grep 'deleted:' | awk '{print \$3}' | xargs git rm -f"

   fi

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# File Management
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
alias packup='/bin/tar -czvf'
alias unpack='/bin/tar -xzvpf'
alias contents='/bin/tar -tzf'
alias du='du -h'
alias df='df -h'

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Working Environment and Productivity Management
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# System Management - CLI
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
alias runlevels='sudo sysv-rc-conf'

# Network Monitoring
alias watch-net='sudo lsof -i -r'
alias http-head='wget --server-response --spider '

	# make a temp dir, then immediately cd into it
alias mktd='tdir=`mktemp -d` && cd $tdir'

# Misc Notes
alias refresh=' . ~/.bashrc'
alias web='w3m'
# myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `

# asks for confirmation everytime 'rm' is used
alias rm='rm -iv'

# History
alias hist='history | grep $1 '

# ls Aliases
# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
alias fgrep='grep --fixed-strings --color=auto'
alias egrep='grep --extended-regexp --color=auto'

# Pager Aliases
alias tf='tail -f'

# Navigation
alias ..='cd ..'
alias cd..='cd ..'
alias ...='cd ../..'

# Processes
alias ps='ps -ef | ${PAGER}'

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Shortcuts specific to functionality of server
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

### MySQL Aliases
if [[ -x /usr/bin/mysql ]]; then
    alias mysql-status='mysqladmin -p status'               # Gives a short status message from the server
    alias mysql-ext-status='mysqladmin -p extended-status'  # Gives an extended status message from the server
    alias mysql-create='mysqladmin -p create'               # Create a new database
    alias mysql-drop='mysqladmin -p drop'                   # Delete a database and all its tables   
    alias mysql-flush-hosts='mysqladmin -p flush-hosts'      # Flush all cached hosts
    alias mysql-flush-logs='mysqladmin -p flush-logs'        # Flush all logs
    alias mysql-flush-status='mysqladmin -p flush-status'    # Clear status variables
    alias mysql-flush-tables='mysqladmin -p flush-tables'    # Flush all tables
    alias mysql-flush-threads='mysqladmin -p flush-threads'  # Flush the thread cache
    alias mysql-flus-privs='mysqladmin -p flush-privileges'  # Reload grant tables (same as reload)
    alias mysql-kill-threads='mysqladmin -p kill'           # Kill mysql threads
    alias mysql-ping='mysqladmin -p ping'                   # Check if mysqld is alive
    alias mysql-show-procs='mysqladmin -p processlist'      # Show list of active threads in server
    alias mysql-reload='mysqladmin -p reload'               # Reload grant tables
    alias mysql-refresh='mysqladmin -p refresh'             # Flush all tables and close and open logfiles
    alias mysql-shutdown='mysqladmin -p shutdown'           # Take server down

fi

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Web-related application Aliases
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


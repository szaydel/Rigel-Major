#!/bin/bash
###############################################################################
# All my commonly used aliases
#
###############################################################################

# SSH remote connectivity aliases

alias laurapc='ssh neptune01'
alias router='ssh root@router'

# Security and Encryption

	if [ -x $(/usr/bin/ecryptfsd) ]; then # Create aliases if ecryptfs exists
		
		alias secreton='ecryptfs-mount-private'
		alias secretoff='ecryptfs-umount-private'
	fi
	
alias protect-file='openssl aes-256-cbc -a -salt -in $1 -out $1'
# alias genpass='openssl rand -base64 37 | cut -c 1-10'
alias mykey='clear; gpg2 --decrypt ~/Private/mykeys.gpg'
alias adm-pass='clear; gpg2 --decrypt ~/Private/admin-passwords.file.gpg'
alias pwgen='pwgen -ncs'
alias gpg='/usr/bin/gpg2'
alias my-mount-passphrase='printf "%s1d35792c8208974cfba3996b1c1cc0bb\n" '


# Aptitude

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
	fi	

# File Management
alias packup='/bin/tar -czvf'
alias unpack='/bin/tar -xzvpf'
alias contents='/bin/tar -tzf'
alias du='du -h'
alias df='df -h'
alias photos='mount /export/nfs/images'
alias backups='mount /export/nfs/backups'

# System Management - CLI
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

# Work-related
alias workpc='ssh 56.224.33.67'

# Remote Copy
alias rsync='rsync -r -p --rsh=ssh --progress'

# Virtual Machines - Headless
alias vm2='VBoxHeadless --startvm Linux-AMD64-VM2' 
alias vm3='VBoxHeadless --startvm NAS-AMD64-VM3'

# VM Tools
alias vmconvert='/usr/bin/ovftool'

# Web Browser
alias clean-firefox='find ~/.mozilla/firefox/ -type f -name "*.sqlite" -exec sqlite3 {} VACUUM \; '

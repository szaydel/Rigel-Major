# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/login.defs
#umask 022
#

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
export PATH=~/bin:"${PATH}"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# Mount NFS filesystems
if [ -d /export/nfs/backups ] ; then
    mount /export/nfs/backups
fi
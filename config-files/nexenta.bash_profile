  echo
  echo '                            * * *'
  echo '  CAUTION: This appliance is not a general purpose operating system:'
  echo '  managing the appliance via Unix shell is NOT recommended. Please use'
  echo '  management console (NMC). NMC is the command-line interface (CLI) of'
  echo '  the appliance, specifically designed for all command-line interactions.'
  echo '  Using Unix shell without authorization of your support provider may not'
  echo '  be supported and MAY VOID your license agreement. To display the'
  echo '  agreement, please use the following NMC command:'
  echo
  echo '  show appliance license agreement'
  echo

## Source local bashrc file
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
elif [ -f ~/nexenta.bashrc ]; then
  . ~/nexenta.bashrc
fi
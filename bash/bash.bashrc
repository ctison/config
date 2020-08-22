# shellcheck shell=bash

set -o pipefail

shopt -s nullglob

# Disable bash history
unset HISTFILE

# Configure PATH
declare -x PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Configure UMASK
umask 0077

# End of configuration if non interactive
[ -z "$PS1" ] && return

# Configure PS1
if [ "$(id -u)" = 0 ]; then PS1='\[\033[1;31m\]#\[\033[0m\] ' ; else PS1='\[\033[1;32m\]$\[\033[0m\] ' ; fi

shopt -s checkwinsize

# Disable less history
declare -x LESSHISTFILE=-

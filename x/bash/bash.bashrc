# Disable bash history
unset HISTFILE

# Configure PATH
declare -x PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Configure UMASK
umask 0077

# End of configuration if non interactive
[ -z "$PS1" ] && return

# Configure PS1
if [ "`id -u`" = 0 ]; then PS1='\033[1;31m#\033[0m ' ; else PS1='\033[1;32m$\033[0m ' ; fi
if [ "$SHELL" = /bin/bash ]; then
  PS1='\[`if [ $(/usr/bin/id -u) = 0 ]; then echo -en "\033[1;31m"; else echo "\033[1;32m"; fi`\]`/usr/bin/id -un`@`/bin/hostname -s`\[\033[0m\]:\[\033[1;34m\] `pwd` >\[\033[0m\] '
fi

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Disable less history
LESSHISTFILE=-

# Man pages colors
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# Aliases
alias l='ls -lhv --g --color=auto'
alias ll='l -a'
alias diff='diff --color=auto'
alias grep='grep --color=auto'

alias root='sudo bash --login'

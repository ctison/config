# Install to /etc/bash.bashrc or ~/.bashrc

# shellcheck shell=bash
set -euo pipefail
shopt -s nullglob

# Disable bash history
unset HISTFILE

# Configure PATH
declare -x PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Configure UMASK
umask 0077

# End of configuration if non interactive
[ -z "$PS1" ] && return

shopt -s checkwinsize

# Disable less history
declare -x LESSHISTFILE=-

# Starship prompt
if type starship 2>/dev/null >&2; then
  eval "$(starship init bash)"
fi

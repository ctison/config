#!/bin/bash
set -euo pipefail
shopt -s nullglob
shopt -s dotglob
umask 0077

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# $0 -- glob
# $1 -- folder
ft_link() {
  # shellcheck disable=SC2206
  expanded=("$SCRIPT_DIR/_/"$1)
  mkdir -p "$2"
  ln -isv "${expanded[@]}" "$2"
}

is_macos=0
[[ $(uname) = Darwin ]] && is_macos=1
is_linux=0
[[ $(uname) = Linux ]] && is_linux=1

ft_link .agents ~/
ft_link 'bash/*' ~/
ft_link bat ~/.config/
ft_link 'cargo/*' ~/.cargo/
ft_link 'codex/*' ~/.codex/
ft_link 'copilot/*' ~/.copilot/
ft_link 'fish/*' ~/.config/fish/
ft_link fnox ~/.config/
ft_link git ~/.config/
ft_link 'helix/*' ~/.config/helix/
ft_link mise ~/.config/
ft_link 'opencode/*' ~/.config/opencode/
ft_link pi/'agents/*' ~/.config/pi/agents/
ft_link starship/starship.toml ~/.config/
ft_link vim/.vimrc ~/
ft_link 'zed/*' ~/.config/zed/
ft_link zellij ~/.config/
ft_link 'zsh/*' ~/

if (( is_macos )); then
  ft_link alacritty ~/.config/
  ft_link 'nushell/*' ~/Library/'Application Support'/nushell/

  ft_link 'vscode/*' ~/Library/'Application Support/Code/User/'
  ft_link .agents/prompts ~/Library/'Application Support/Code/User/'

  ft_link 'vscode/*' ~/Library/'Application Support/Code - Insiders/User/'
  ft_link '.agents/prompts' ~/Library/'Application Support/Code - Insiders/User/'
elif (( is_linux )); then
  ft_link 'nushell/*' ~/.config/nushell
fi

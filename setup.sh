#!/bin/bash
set -euxo pipefail
shopt -s nullglob
umask 0077

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo ">>> Executed as: $(id)"

# Link configurations
mkdir -p ~/.config/{fish,nushell} ~/.cargo/
ln -isv "$SCRIPT_DIR"/_/bat ~/.config/
ln -isv "$SCRIPT_DIR"/_/cargo/config.toml ~/.cargo/
ln -isv "$SCRIPT_DIR"/_/fish/* ~/.config/fish/
ln -isv "$SCRIPT_DIR"/_/git ~/.config/
ln -isv "$SCRIPT_DIR"/_/mise ~/.config/
ln -isv "$SCRIPT_DIR"/_/ripgrep ~/.config/
ln -isv "$SCRIPT_DIR"/_/starship/starship.toml ~/.config/
ln -isv "$SCRIPT_DIR"/_/vim/vimrc ~/.vimrc
ln -isv "$SCRIPT_DIR"/_/zellij ~/.config/

if [[ $(uname) = Darwin ]]; then
  ln -isv "$SCRIPT_DIR"/_/nushell/* ~/Library/Application\ Support/nushell/
  ln -isv "$SCRIPT_DIR"/_/vscode/* ~/Library/Application\ Support/Code\ -\ Insiders/User/
elif [[ $(uname) = Linux ]]; then
  ln -isv "$SCRIPT_DIR"/_/nushell/* ~/.config/nushell
fi

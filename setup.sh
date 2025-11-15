#!/bin/bash
set -euxo pipefail
shopt -s nullglob
umask 0077

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo ">>> Executed as: $(id)"

# Link configurations
mkdir -p ~/.config/ ~/.cargo/
ln -fsv "$SCRIPT_DIR"/cargo/config.toml ~/.cargo/
ln -fsv "$SCRIPT_DIR"/fish ~/.config/
ln -fsv "$SCRIPT_DIR"/git ~/.config/
ln -fsv "$SCRIPT_DIR"/mise ~/.config/
ln -fsv "$SCRIPT_DIR"/starship/starship.toml ~/.config/
# cSpell:words vimrc
ln -fsv "$SCRIPT_DIR"/vim/vimrc ~/.vimrc
ln -fsv "$SCRIPT_DIR"/zellij ~/.config/

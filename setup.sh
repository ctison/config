#!/bin/bash
set -euxo pipefail
shopt -s nullglob

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo ">>> Executed as: $(id)"

# Link configurations
mkdir -pm 0700 ~/.config/
ln -fsv "$SCRIPT_DIR"/bash/bash.bashrc ~/.bashrc
ln -fsv "$SCRIPT_DIR"/direnv ~/.config/
ln -fsv "$SCRIPT_DIR"/fish ~/.config/
ln -fsv "$SCRIPT_DIR"/git ~/.config/
ln -fsv "$SCRIPT_DIR"/nushell ~/.config/
ln -fsv "$SCRIPT_DIR"/rtx ~/.config/
ln -fsv "$SCRIPT_DIR"/starship/starship.toml ~/.config/
ln -fsv "$SCRIPT_DIR"/tmux ~/.config/
ln -fsv "$SCRIPT_DIR"/vim/vimrc ~/.vimrc

# Install nushell
"$SCRIPT_DIR/bin/install-nushell"

export PATH="$HOME/.local/bin:$PATH"

# Install tools
gpm cli/cli
gpm direnv/direnv
gpm muesli/duf
gpm bootandy/dust
gpm sharkdp/fd
gpm jesseduffield/lazygit
gpm koalaman/shellcheck
gpm rliebz/tusk
gpm ducaale/xh --libc musl        # TODO remove --libc musl when possible
gpm starship/starship --libc musl # TODO remove --libc musl when possible
gpm sharkdp/bat
gpm junegunn/fzf
gpm BurntSushi/ripgrep --arch x86_64 --libc musl # NO BUILD FOR ARM64
gpm jdxcode/rtx

if type fish >/dev/null 2>&1; then
  chsh -s /usr/bin/fish
  fish -c fish_update_completions
fi

#!/bin/bash
set -euo pipefail
shopt -s nullglob

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo '>>> Executed as:'
id

if type apt-get >/dev/null 2>&1; then
  # shellcheck disable=SC2034
  DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y fish curl jq sed tar
  mkdir -p ~/.config && ln -s /config/fish ~/.config/fish
  chsh -s /usr/bin/fish
  useradd -D -s /usr/bin/fish
  fish -c fish_update_completions
  bash "${SCRIPT_DIR}/bin/install/direnv"
  bash "${SCRIPT_DIR}/bin/install/fd"
  bash "${SCRIPT_DIR}/bin/install/fnm"
  bash "${SCRIPT_DIR}/bin/install/gh"
  bash "${SCRIPT_DIR}/bin/install/lazygit"
  bash "${SCRIPT_DIR}/bin/install/ripgrep"
  bash "${SCRIPT_DIR}/bin/install/shellcheck"
  bash "${SCRIPT_DIR}/bin/install/tusk"
  bash "${SCRIPT_DIR}/bin/install/xh"
fi

if type apk >/dev/null 2>&1; then
  apk add --no-cache fish
  mkdir -p ~/.config && ln -s /config/fish ~/.config/fish
  chsh -s /usr/bin/fish
  useradd -D -s /usr/bin/fish
  fish -c fish_update_completions
fi

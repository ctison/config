set fish_color_autosuggestion      777777
set fish_color_command             00FF00
set fish_color_comment             30BE30
set fish_color_cwd                 green
set fish_color_cwd_root            red
set fish_color_end                 FF7B7B
set fish_color_error               A40000
set fish_color_escape              cyan
set fish_color_history_current     cyan
set fish_color_host                '-o' 'cyan'
set fish_color_match               cyan
set fish_color_normal              normal
set fish_color_operator            cyan
set fish_color_param               30BE30
set fish_color_quote               44FF44
set fish_color_redirection         7BFF7B
set fish_color_search_match        --background=purple
set fish_color_selection           --background=purple
set fish_color_status              red
set fish_color_user                '-o' 'green'
set fish_color_valid_path          --underline

umask 0077

if test (uname -s) = Darwin
  alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
  set -a PATH /Library/Developer/CommandLineTools/usr/bin
end

if type -q git 2>/dev/null
  alias gs='git status --short --branch'
  alias gl='git log --pretty=oneline'
  alias gc='git commit'
  alias gp='git push'
  alias ga='git add'
  alias gr='git remote'
end

if type -q kubectl 2>/dev/null
  alias k=kubectl
  alias kz='kubectl kustomize'
end

if type -q kubebuilder 2>/dev/null
  alias kb=kubebuilder
end

function setupConfig -a CONFIGPATH
  if type -q tusk 2>/dev/null && test -f "$CONFIGPATH/x/tusk/tusk.yaml"
    alias x="tusk -f '$CONFIGPATH/x/tusk/tusk.yaml'"
  end
  set -p PATH $CONFIGPATH/bin
end

if test -d ~/config/.git
  setupConfig ~/config
else if test -d ~/work/config/.git
  setupConfig ~/work/config
else if test -d /config/.git
  setupConfig /config
end

functions -e setupConfig

if type -q gpg 2>/dev/null
  alias gpg='gpg --keyid-format long'
  set -gx GPG_TTY (tty)
end

if type -q docker-compose 2>/dev/null
  alias dc=docker-compose
end
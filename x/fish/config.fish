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

if test -d ~/work/bin
  set -p PATH ~/work/bin
end

if test -d ~/.cargo/bin
  set -a PATH ~/.cargo/bin
end

if test -d /snap/bin
  set -a PATH /snap/bin
end

if type -q git 2>/dev/null
  alias gs='git status --short --branch'
  alias gl='git log --pretty=oneline'
end

if type -q kubectl 2>/dev/null
  alias k=kubectl
  alias kz='k kustomize'
  if not set -q KUBECONFIG && test -f ~/.kube/configs/docker-desktop.yaml
    set -gx KUBECONFIG ~/.kube/configs/docker-desktop.yaml
  end
  alias ls-k8s='l ~/.kube/configs/*'
  alias set-k8s='set -gx KUBECONFIG'
end

if type -q pulumi 2>/dev/null
  alias p=pulumi
  alias set-pulumi='set -gx PULUMI_CONFIG_PASSPHRASE'
end

if type -q kubebuilder 2>/dev/null
  alias kb=kubebuilder
end

function setupConfig -a CONFIGPATH
  if type -q tusk 2>/dev/null && test -f "$CONFIGPATH/x/tusk/tusk.yaml"
    alias x="tusk -f '$CONFIGPATH/x/tusk/tusk.yaml'"
  end
  set -p PATH $CONFIGPATH/bin
  alias man="man -P $CONFIGPATH/bin/pager"
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

if grep -E ~/.vscode-server/bin/'[[:alnum:]]+'/bin/code (type -p code 2>/dev/null | psub) >/dev/null 2>&1
  set -gx EDITOR 'code -w'
end

if not test -f /var/run/docker.sock && type -q host 2>/dev/null && host -W1 docker >/dev/null 2>&1
  set -gx DOCKER_HOST 'tcp://docker:2375'
end

if type -q terraform 2>/dev/null
  alias tf='terraform'
end

if type -q aws 2>/dev/null
  alias ls-aws='grep -Po \'^\[profile \K([[:alpha:]]+)(?=]$)\' ~/.aws/config'
  alias set-aws='set -gx AWS_PROFILE'
end

if type -q gcloud 2>/dev/null
  alias ls-gcp='gcloud config configurations list'
  alias set-gcp='set -gx CLOUDSDK_ACTIVE_CONFIG_NAME'
end

if type -q shellcheck 2>/dev/null
  alias shellcheck='shellcheck -f gcc'
end

if type -q octant 2>/dev/null
  alias octant='octant --disable-open-browser --listener-addr 0.0.0.0:7777'
end

if type -q hasura 2>/dev/null
  alias hasura='hasura --skip-update-check'
end

if type -q tar 2>/dev/null
  alias tar='tar --no-same-o --no-same-p'
end
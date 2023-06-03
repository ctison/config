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

functions -e l ll

if test (uname -s) = Darwin
  alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
end

if test -d ~/.cargo/bin
  set -a PATH ~/.cargo/bin
end
if test -d /snap/bin
  set -a PATH /snap/bin
end

if test -d ~/.local/bin
  set -a PATH ~/.local/bin
end

if test -d ~/.poetry/bin
  set -a PATH ~/.poetry/bin
end

if test -d ~/gpm/bin
  set -a PATH ~/gpm/bin
end

if test -d ~/work/bin
  set -a PATH ~/work/bin
end

if test -d /opt/homebrew/bin
  set -p PATH /opt/homebrew/bin
end

if test -d ~/.docker/bin
  set -p PATH ~/.docker/bin
end

if type -q kubectl 2>/dev/null
  alias k=kubectl
  alias kz='k kustomize'
  function kd -w 'kubectl diff'
    KUBECTL_EXTERNAL_DIFF='difft' kubectl diff $argv
  end
  function kdd -w 'kubectl diff'
    KUBECTL_EXTERNAL_DIFF='delta' kubectl diff $argv
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

if type -q gpg 2>/dev/null
  alias gpg='gpg --keyid-format long'
  set -gx GPG_TTY (tty)
end

if type -q docker 2>/dev/null
  alias dc='docker compose'
  alias dx='docker buildx'
  set -gx DOCKER_BUILDKIT 1
end

if grep -E ~/.vscode-server/bin/'[[:alnum:]]+'/bin/code (type -p code 2>/dev/null | psub) >/dev/null 2>&1 || type -q code 2>/dev/null
  set -gx EDITOR 'code -w'
end

if type -q terraform 2>/dev/null
  alias tf='terraform'
end

if type -q aws 2>/dev/null
  alias ls-aws='rg -NPo \'^\[profile \K(.+)(?=]$)\' ~/.aws/config'
  alias set-aws='set -gx AWS_PROFILE'
end

if type -q gcloud 2>/dev/null
  alias ls-gcp='gcloud config configurations list'
  alias set-gcp='gcloud config configurations activate'
end

if type -q shellcheck 2>/dev/null
  alias shellcheck='shellcheck -f gcc'
end

if type -q octant 2>/dev/null
  alias octant='octant --listener-addr 0.0.0.0:7777'
end

if type -q hasura 2>/dev/null
  alias hasura='hasura --skip-update-check'
end

if type -q tar 2>/dev/null
  alias tar='tar --no-same-o --no-same-p'
end

if type -q hub 2>/dev/null
  alias hub='env GITHUB_TOKEN="$GITHUB_TOKEN" hub'
end

if type -q mkdir 2>/dev/null
  alias mkdir='mkdir -p'
  alias m='mkdir'
end

if type -q pip 2>/dev/null
  alias pip='pip --use-feature=2020-resolver'
end

if type -q go 2>/dev/null
  set -gx GO111MODULE on
end

if test -d ~/go/bin
  set -a PATH ~/go/bin
end

if type -q gem 2>/dev/null
  set -gx GEM_HOME "$HOME/.gem"
  set -p PATH $GEM_HOME/ruby/*/bin
end

if type -q git 2>/dev/null
  alias g='git'
end

if type -q code-insiders 2>/dev/null
  set -gx EDITOR 'code-insiders -w'
  alias code='code-insiders'
  alias vscode='command code'
end

if type -q brew 2>/dev/null
  alias b='brew'
end

if test -d /opt/homebrew/bin
  set -p PATH /opt/homebrew/bin
end

if type -q arch 2>/dev/null
  function x86
    set -lx PATH (string replace -ar '^/opt/homebrew/bin$' '' $PATH)
    set -p PATH /usr/local/opt/node@14/bin
    arch -x86_64 $argv
  end
end

if type -q exa 2>/dev/null
  alias l='exa -lag --group-directories-first --git'
  alias t='l -T'
end

if type -q direnv 2>/dev/null
  alias da='direnv allow'
end

if type -q gcloud 2>/dev/null
  alias gi='gcloud beta interactive'
end

### Setup config

function setupConfig -a CONFIGPATH
  if type -q tusk 2>/dev/null && test -f "$CONFIGPATH/tusk/tusk.yaml"
    alias x="tusk -f '$CONFIGPATH/tusk/tusk.yaml'"
  end
  set -p PATH $CONFIGPATH/bin
  alias man="man -P $CONFIGPATH/bin/pager"
  set -gx PAGER $CONFIGPATH/bin/pager
  alias .j="j -f $CONFIGPATH/justfile -d (pwd)"
end

if test -f ~/config/Dockerfile
  setupConfig ~/config
else if test -f ~/work/config/Dockerfile
  setupConfig ~/work/config
else if test -f ~/x/config/Dockerfile
  setupConfig ~/x/config
else if test -f /config/tusk/tusk.yaml
  setupConfig /config
else if test -f ~/Documents/Work/ctison/config/Dockerfile
  setupConfig ~/Documents/Work/ctison/config
end

functions -e setupConfig

if type -q starship 2>/dev/null
  starship init fish | source
end

function mkcd -d "Create a directory and set CWD" -w mkdir
  command mkdir $argv
  if test $status = 0
    switch $argv[(count $argv)]
      case '-*'
      case '*'
        cd $argv[(count $argv)]
        return
    end
  end
end

if test -d /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/
  set -a PATH /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/
end

if type -q docker-machine 2>/dev/null
  alias dm='docker-machine'
end

if test -d ~/.pyenv/bin
  set -a PATH ~/.pyenv/bin ~/.pyenv/shims
end

if type -q just 2>/dev/null
  alias j='just --chooser sk'
end

if type -q k9s 2>/dev/null
  alias k9s='k9s --logoless --headless -c pu'
end

if type -q kustomize 2>/dev/null
  alias kt='kustomize cfg tree -'
  alias kg='kustomize cfg grep --annotate=false'
end

if test -d ~/.krew/bin
  set -a PATH ~/.krew/bin
end

if type -q direnv 2>/dev/null
  direnv hook fish | source
end

# if type -q fnm 2>/dev/null
#   eval (fnm env)
# end


if type -q rtx 2>/dev/null
  # set -gx RTX_LOG_LEVEL debug
  rtx activate fish | source
end


if type -q mcfly 2>/dev/null
  mcfly init fish | source
end

if type -q lazygit 2>/dev/null
  alias lg='lazygit'
end

if type -q zellij 2>/dev/null
  alias z='zellij'
end

if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
  eval /opt/homebrew/Caskroom/miniconda/base/bin/conda "shell.fish" "hook" $argv | source
end

# if test "$TERM_PROGRAM" = 'vscode'
#   set -l fishIntegrationPath (code --locate-shell-integration-path fish)
#   if test -f "$fishIntegrationPath"
#     source "$fishIntegrationPath"
#   end
# end

# if test -S ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
#   set -gx SSH_AUTH_SOCK ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
# end

set -gx CARGO_REGISTRIES_CRATES_IO_PROTOCOL sparse

# The next line updates PATH for the Google Cloud SDK.
if [ -f ~/google-cloud-sdk/path.fish.inc ]
  source ~/google-cloud-sdk/path.fish.inc
end

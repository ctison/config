use ./scripts/cfg
cfg log debug $'>>> Loading (cfg fmt -bu config.nu)'

cfg state start

if (which mise | is-not-empty) { cfg mise activate }

$env.config.show_banner = false
$env.config.table.index_mode = 'auto'
$env.config.footer_mode = 'never'
$env.config.highlight_resolved_externals = true

use ./scripts/adb
use ./scripts/docker
use ./scripts/gh
use ./scripts/npm
use ./scripts/macos
use ./scripts/web3

$env.config.hooks.pre_prompt ++= [{
  $env.NU_OVERLAYS = (overlay list | where active | get name | str join ',')
}]
$env.config.hooks.pre_execution ++= [{
  hide-env -i ...[
    NU_OVERLAYS
  ]
}]
source ($nu.cache-dir | path join starship.nu)
source ($nu.cache-dir | path join carapace.nu)

def --env mkcd [path: string] { mkdir $path; cd $path }

alias bh     = bat -l help --style=-full,grid
alias dc     = docker compose
alias e      = table -e
alias fd     = fd -H --no-require-git -s --one-file-system --prune --hyperlink=auto
alias g      = git
alias gpg    = gpg --keyid-format long # cSpell:ignore keyid
alias h      = xh https://httpbin.org/anything
def   hl     [] { '' | fill -w (term size).columns -c '-' }
alias k      = kubectl
alias k9s    = k9s --logoless --headless -c pu
alias kg     = kustomize cfg grep --annotate=false
alias kt     = kustomize cfg tree -
alias kz     = kubectl kustomize --enable-helm
alias l      = eza -lagMnO --group-directories-first --no-quotes --time-style=long-iso --no-time
alias lg     = lazygit
alias lh     = l --hyperlink
alias ll     = l -a@Z
alias p      = pulumi
alias scrcpy = scrcpy --legacy-paste
alias t      = l -T
alias tar    = tar --no-same-o --no-same-p2
alias v      = vim
alias z      = zellij
alias ze     = zellij e
alias zo     = zellij options
alias ytba   = youtube-dl -f bestaudio -o '%(channel)s - %(title)s.%(ext)s'
# cSpell:ignore ytba scrcpy

if (which rg | is-not-empty) {
  $env.RIPGREP_CONFIG_PATH = $cfg.DIR | path join 'ripgrep' 'config'
}

if (which gpg | is-not-empty) { $env.GPG_TTY = ^tty }

'~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh'
| do-if {path type | $in == socket} { $env.SSH_AUTH_SOCK = ($in | path expand) }

# cSpell:ignore MANROFFOPT
$env.MANROFFOPT = '-c'
$env.MANPAGER = $cfg.DIR_BIN | path join pager

@complete external
def --wrapped brew [...rest] {
  $env.HOMEBREW_NO_INSECURE_REDIRECT = 1
  $env.HOMEBREW_VERIFY_ATTESTATIONS = 1
  $env.HOMEBREW_NO_ANALYTICS = 1
  $env.HOMEBREW_UPGRADE_GREEDY = 1
  $env.HOMEBREW_BAT = 1
  ^brew ...$rest
}

cfg log debug $'<<< Exiting (cfg fmt -bu config.nu)'

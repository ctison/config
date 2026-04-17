use ../scripts/utils/cfg.nu

def --env mkcd [path: string] { mkdir $path; cd $path }

alias bh     = bat -l help --theme Dracula --style=-full,grid --paging=always
alias c      = cargo
alias d      = docker
alias dc     = docker compose
alias dm     = docker model
alias e      = table -e
alias fd     = fd -H --no-require-git -s --one-file-system --prune --hyperlink=auto
alias g      = git
alias gpg    = gpg --keyid-format long # cSpell:ignore keyid
def   hl     [] { '' | fill -w (term size).columns -c '─' | ansi gradient --fgstart '0x40c9ff' --fgend '0xe81cff' }
# cSpell:ignore fgstart fgend
alias k      = kubectl
alias k9s    = k9s --logoless --headless -c pu
alias kg     = kustomize cfg grep --annotate=false
alias kt     = kustomize cfg tree -
alias kz     = kubectl kustomize --enable-helm
alias l      = eza -lagMnOa --group-directories-first --no-quotes --time-style=long-iso --no-time
alias lg     = lazygit
alias lh     = l --hyperlink
alias ll     = l -@Z
alias o      = ^open
alias p      = pulumi
alias scrcpy = scrcpy --legacy-paste
alias t      = eza -lagMnO --group-directories-first --no-quotes --time-style=long-iso --no-time -T --hyperlink
alias tar    = tar --no-same-owner --no-same-permissions
alias v      = vim
alias z      = zellij
alias ze     = zellij e
alias zo     = zellij options
alias ytba   = yt-dlp -f bestaudio -o '%(channel)s - %(title)s.%(ext)s'
# cSpell:ignore ytba scrcpy

if (which rg | is-not-empty) {
  $env.RIPGREP_CONFIG_PATH = $cfg.DIR | path join 'ripgrep' 'config'
}

if (which gpg | is-not-empty) and (which tty | is-not-empty) {
  $env.GPG_TTY = ^tty
}

'~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh'
| if ($in | path type | $in == socket) { $env.SSH_AUTH_SOCK = ($in | path expand) }

alias nu-help = help

def --wrapped help [
  --find(-f): string
  ...rest
] {
  if $find != null {
    nu-help --find=($find) ...$rest
  } else {
    nu-help ...$rest
  }
  | bh --color=never
}

def --wrapped h [...rest] {
  try {
    help ...$rest | table -e | bh --color=never
  } catch {|err|
    if ($err.msg starts-with 'Not found') {
      run-external ...$rest '--help' | bh
    } else $err
  }
}

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

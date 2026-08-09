# cSpell:ignore ytba scrcpy keyid fgstart fgend yazi

def --env mkcd [path: path] {
  mkdir -v $path
  cd $path
}

alias bh     = bat -l help --theme Dracula --style=-full,grid --paging=always
alias dps    = docker ps
alias ed     = zellij e -f --height 100
alias fd     = fd -H --no-require-git -s --one-file-system --prune --hyperlink=auto
alias fdd    = fd -H --no-require-git -s --one-file-system --prune --hyperlink=auto --search-path
alias g      = git
alias gpg    = gpg --keyid-format long
def   hl     [] { '' | fill -w (term size).columns -c '─' | ansi gradient --fgstart '0x40c9ff' --fgend '0xe81cff' }
alias k      = kubectl
alias k9s    = k9s --logoless --headless -c pu
alias kg     = kustomize cfg grep --annotate=false
alias kt     = kustomize cfg tree -
alias kz     = kubectl kustomize --enable-helm
alias lg     = lazygit
alias lh     = l --hyperlink
alias ll     = l -@Z
alias nv     = nvim
alias op     = ^open
alias p      = pulumi
alias scrcpy = scrcpy --legacy-paste
alias t      = table -e
alias tar    = tar --no-same-owner --no-same-permissions
alias tree   = eza -lagMnO --group-directories-first --no-quotes --time-style=long-iso --no-time -T --hyperlink
alias v      = nvim
alias z      = zellij
alias zo     = zellij options
alias ytba   = yt-dlp -f bestaudio -o '%(channel)s - %(title)s.%(ext)s'

if (has-tool gpg) and (has-tool tty) {
  $env.GPG_TTY = ^tty
}

def zd [] {
  zellij ac dump-screen -f | pbcopy
}

def zz --wrapped [...rest] {
  if $env.ZELLIJ_PARENT_SESSION_NAME? != null {
    with-env {
      ZELLIJ_SESSION_NAME: $env.ZELLIJ_PARENT_SESSION_NAME
    } {
      zellij ...$rest
      | return $in
    }
  }
  with-env {
    ZELLIJ_PARENT_SESSION_NAME: $env.ZELLIJ_SESSION_NAME
  } {
    exec zellij options --pane-frames true ...$rest
  }
}

def w [...rest] {
  which -a ...$rest
  | each { if $in.type == external { update path { eza } } else $in }
}

'~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh'
| if ($in | path type | $in == socket) { $env.SSH_AUTH_SOCK = ($in | path expand) }

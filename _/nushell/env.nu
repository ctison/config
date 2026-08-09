$env.SHELL  = 'nu'
$env.LC_ALL = 'C'
$env.DO_NOT_TRACK = 1

const DIR_SELF = path self | path expand | path dirname
source ($DIR_SELF)/base/_.nu
source ($DIR_SELF)/helpers/_.nu
source ($DIR_SELF)/stubs/_.nu
unlet $DIR_SELF

# Restore state after reload
do --env {
  $env.__RELOAD? | if $in != null { state set $. { $in | from json } }
  hide-env -i __RELOAD
}

# Configure $PATH
env-path add ...[
  $cfg.DIR_BIN
  /sbin /usr/sbin
  /bin /usr/bin
  ~/.cargo/bin
  ~/.bun/bin
  ~/go/bin
  ...(if (has-tool mise) and not $nu.is-interactive { [~/.local/share/mise/shims] } else [])
  /opt/homebrew/bin
  ~/.local/bin
  ~/.docker/bin
]

if $nu.is-interactive {
  # Activate mise
  if (has-tool mise) {
    touch ~/.config/mise/config.toml
    mise activate
  }

  if $env.ZELLIJ? != null and $env.ZELLIJ_PARENT_SESSION_NAME? == null {
    with-env {
      ZELLIJ_PARENT_SESSION_NAME: $env.ZELLIJ_SESSION_NAME
    } {
      exec zellij options --pane-frames true --theme ao
    }
  }

  mkdir $nu.cache-dir

  # Activate starship
  if (has-tool starship) {
    starship init nu | save -f $cfg.__STARSHIP
  }
}

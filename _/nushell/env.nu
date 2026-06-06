$env.SHELL  = 'nu'
$env.LC_ALL = 'C'
$env.DO_NOT_TRACK = 1

const DIR_SELF = path self | path expand | path dirname
source ($DIR_SELF | path join base _.nu)
source ($DIR_SELF | path join helpers _.nu)
source ($DIR_SELF | path join stubs _.nu)
unlet $DIR_SELF

# Restore state after reload
do --env {
  $env.__RELOAD? | if $in != null { state set $. { $in | from json } }
  hide-env -i __RELOAD
}

# Configure $PATH
env-path add ...[
  $cfg.DIR_BIN
  /sbin /usr/sbin /bin /usr/bin
  /opt/homebrew/bin
  ~/.local/bin ~/.docker/bin ~/.cargo/bin ~/.bun/bin ~/go/bin
]

# If interactive
if $nu.is-interactive {
  # Activate mise
  if (has-tool mise) {
    touch ~/.config/mise/config.toml
    mise activate
  }

  # Save dynamic code to files that will be sourced by `config.nu`
  mkdir $nu.cache-dir

  if (has-tool starship) {
    starship init nu | save -f $cfg.__STARSHIP
  }
}

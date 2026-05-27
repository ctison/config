$env.SHELL  = 'nu'
$env.LC_ALL = 'C'

@complete external
def nu [] { ^($nu.current-exe) }

const SELF = path self
source ($SELF | path expand | path dirname | path join 00 _.nu)
source ($SELF | path expand | path dirname | path join 01 _.nu)
unlet $SELF

# Restore state after reload
do --env {
  $env.__RELOAD? | if $in != null { state set $. { $in | from json } }
  hide-env -i __RELOAD
}

# Configure $PATH
env-path add ...[
  $cfg.DIR_BIN
  /sbin /usr/sbin /bin /usr/bin
  ~/.cargo/bin ~/go/bin
  ~/.local/bin ~/.docker/bin ~/.bun/bin
  /opt/homebrew/bin
]

const __STARSHIP = $nu.cache-dir | path join starship.nu

# If interactive
if $nu.is-interactive {
  # Activate mise
  if (has-tool mise) {
    touch ~/.config/mise/config
    mise activate
  }

  # Save dynamic code to files that will be sourced by `config.nu`
  mkdir $nu.cache-dir

  if (has-tool starship) {
    starship init nu | save -f $__STARSHIP
  }
}

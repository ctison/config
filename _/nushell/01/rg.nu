export const RIPGREP_CONFIG_PATH = $cfg.DIR_ | path join 'ripgrep' 'config'

@complete external
export def --wrapped main [...rest] {
  with-env {
    RIPGREP_CONFIG_PATH: $RIPGREP_CONFIG_PATH
  } {
    log debug { $'RIPGREP_CONFIG_PATH: ($env.RIPGREP_CONFIG_PATH)' }
    ^rg ...$rest
  }
}

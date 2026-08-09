$env.config.show_banner = false
$env.config.table.index_mode = 'auto'
$env.config.footer_mode = 10
$env.config.highlight_resolved_externals = true
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

source (if $nu.is-interactive { $cfg.__STARSHIP } else null)

const DIR_SELF = path self | path expand | path dirname
source (if $nu.is-interactive { ($DIR_SELF)/tools/_.nu } else null)
unlet $DIR_SELF

if $nu.is-interactive {
  $env.NU_PLUGIN_DIRS = [
    ($nu.current-exe | path dirname)
    ('~/.cargo/bin' | path expand)
  ]

  $env.MANROFFOPT = '-c' # cSpell:ignore MANROFFOPT
  $env.MANPAGER = ($cfg.DIR_BIN)/man-pager.nu
}

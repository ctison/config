$env.config.show_banner = false
$env.config.table.index_mode = 'auto'
$env.config.footer_mode = 10
$env.config.highlight_resolved_externals = true
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

const __STARSHIP = if $nu.is-interactive { $cfg.__STARSHIP } else null
source $__STARSHIP
unlet $__STARSHIP

const DIR_SELF = path self | path expand | path dirname
source ($DIR_SELF | path join stubs _.nu)
source ($DIR_SELF | path join tools _.nu)
unlet $DIR_SELF

$env.NU_PLUGIN_DIRS = [
  ($nu.current-exe | path dirname)
  ('~/.cargo/bin' | path expand)
]

$env.config.show_banner = false
$env.config.table.index_mode = 'auto'
$env.config.footer_mode = 10
$env.config.highlight_resolved_externals = true
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true


const __STARSHIP = if $nu.is-interactive { $__STARSHIP } else null
source $__STARSHIP

unlet $__STARSHIP

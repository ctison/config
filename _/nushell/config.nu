use ./scripts/utils/log.nu
const self = path self | path expand
log scope --enter $self

$env.config.show_banner = false
$env.config.table.index_mode = 'auto'
$env.config.footer_mode = 'never'
$env.config.highlight_resolved_externals = true
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

source ./scripts/utils/__source.nu
source ./scripts/__source.nu

source ($nu.cache-dir | path join starship.nu)
source ($nu.cache-dir | path join carapace.nu)

log scope --exit $self

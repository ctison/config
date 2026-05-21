export def update [] {
  if $nu.os-info.name == 'macos' {
    log info 'Upgrading Homebrew packages'
    brew upgrade
  }

  log info 'Upgrading mise tools'
  mise up

  log info 'Upgrading UV tools'
  uv tool upgrade --all

  log info 'Upgrading Cargo packages'
  cargo install --list | lines | where $in !~ ^\s | each {split row ' ' | $in.0}
  | cargo install ...$in
}

export alias up = update

const CARGO_BINS = [
  'cargo-edit',
  'nu_plugin_regex'
]

export def init [] {
  $CARGO_BINS
  | input list --fuzzy --per-column --multi
  | cargo install ...$in
}

export def 'uv ls' [] {
  uv tool list
}

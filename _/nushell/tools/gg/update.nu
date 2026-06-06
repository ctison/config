export const CARGO_BINS = [
  'cargo-edit',
  'nu_plugin_regex'
]

export def main [reenter = 0] {
  if $reenter <= 0 {
    if $nu.os-info.name == 'macos' {
      log info 'Upgrading Homebrew packages'
      brew upgrade
    }
  }

  if $reenter <= 1 {
    log info 'Upgrading mise tools'
    # mise up
  }

  if $reenter <= 2 {
    log info 'Upgrading UV tools'
    uv tool upgrade --all
  }

  if $reenter <= 3 {
    log info 'Upgrading Cargo packages'
    cargo install --list | lines | where $in !~ ^\s | each {split row ' ' | $in.0}
    | cargo install ...$in
  }

  if $reenter <= 4 {
    log info 'Upgrading Bun tools'
    bun update --global --latest
  }
}

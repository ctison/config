export const CARGO_BINS = [
  'cargo-edit',
  'nu_plugin_regex'
]

export def main [...tools: string] {
  $tools
  | default {
    [
      ...(if $nu.os-info.name == 'macos' {['brew']} else [])
      mise
      uv
      cargo
      bun
    ]
    | input list --multi
  }
  | let choices

  if 'brew' in $choices {
    log info 'Upgrading Homebrew packages'
    brew upgrade
  }

  if 'mise' in $choices {
    log info 'Upgrading mise tools'
    mise up
  }

  if 'uv' in $choices {
    log info 'Upgrading UV tools'
    uv tool upgrade --all
  }

  if 'cargo' in $choices {
    log info 'Upgrading Cargo packages'
    open ~/.cargo/.crates2.json
    | $in.installs
    | items {|k v| [$k $v]}
    | where $it.0 !~ '\(path\+'
    | par-each {
      cargo install ($in.0 | split row ' ' | get 0) ...(
        $in.1.features
        | if ($in | is-not-empty) {
          ['--features' ($in | str join ',')]
        } else []
      )
    }
  }

  if 'bun' in $choices {
    log info 'Upgrading Bun tools'
    bun update --global --latest
  }
}

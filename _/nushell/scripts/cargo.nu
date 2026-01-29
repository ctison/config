use ./utils/log.nu

export def api [...packages: string]: [
  oneof<nothing, string, list<string>> -> table
] {
  append $packages | par-each -k {
    http get $'https://crates.io/api/v1/crates/($in)'
  }
}

export def fetch-versions [...packages: string]: [
  oneof<nothing, string, list<string>> -> table
] {
  append $packages | each -f {
    if '{' in $in {$in | str expand} else $in
  } | [($in | api | each {
    $'($in.crate.name) = { version = "($in.crate.max_stable_version)" }'
  }) "\n" ($in | each {
    $'($in) = { workspace = true }'
  })] | flatten | str join (char newline) | tee {pbcopy}
}

export def find-root-package []: nothing -> path {
  cargo metadata --format-version 1 --no-deps
  | from json
  | $in.workspace_root
  | path join 'Cargo.toml'
}

export def add-dep [...pkgs: string] {
  let rootPackage = find-root-package

  let pkgsToVersions = $in
    | append $pkgs
    | each -f { if '{' in $in {$in | str expand} else $in }
    | api
    | $in.crate
    | each { {$in.name: $in.max_stable_version} }
    | into record
    # | tee { log info -r $in }

  $pkgsToVersions
  | items {|k v| $'($k) = { workspace = true }'}
  | str join (char newline)
  | tee { pbcopy $in }

  $pkgsToVersions
  | items {|k v| $"($k) = { version = '($v)' }" }
  | str join (char newline)
  | tee { pbcopy $in }

  $pkgsToVersions
}

export def dev [] {
  watchexec -r -e .rs cargo build
}

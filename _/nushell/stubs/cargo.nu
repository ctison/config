@complete external
export def --wrapped main [...rest] {
  with-env {
#    CARGO_HOME: ($cfg.DIR_)/cargo
    RUSTFLAGS: -Awarnings
    RUST_BACKTRACE: full
  } {
    cargo ...$rest
  }
}

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

export def find-root-package [
  --cargo # use cargo
]: nothing -> path {
  if $cargo {
    cargo metadata --format-version 1 --no-deps
    | from json
    | $in.workspace_root
    | path join 'Cargo.toml'
  } else {
    mut dir = pwd
    loop {
      try {
        ($dir)/Cargo.toml
        | let cargoTomlPath
        | open $in
        | let cargoToml
        if 'workspace' in $cargoToml {
          log info $'Found route crate: ($cargoTomlPath)'
          return $cargoTomlPath
        }
      }
      let parentDir = $dir | path dirname
      if $parentDir == $dir { break }
      $dir = $parentDir
    }
  }
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
    # | tee { log info -R $in }

  $pkgsToVersions
  | items {|k v| $'($k) = { workspace = true }'}
  | str join (char newline)
  | tee { pbcopy }

  $pkgsToVersions
  | items {|k v| $"($k) = { version = '($v)' }" }
  | str join (char newline)
  | tee { pbcopy }

  $pkgsToVersions
}

export def dev [] {
  watchexec -r -e .rs cargo build
}

export def list-all-deps [] {
  find-root-package
  | open $in
  | select workspace.dependencies
  | update 'workspace.dependencies' {
    items {|k v|
      if ($v | describe) starts-with record and $v.path? != null { null } else [$k $v]
    } | into record
  }
}

export def 'global upgrade' [] {
  cargo install --list
  | lines
  | where $in !~ ^\s
  | each { split row ' ' | $in.0 }
  | cargo install ...$in
}

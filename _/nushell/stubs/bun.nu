@complete external
export def --wrapped main [...rest] {
  with-env {
    BUN_FEATURE_FLAG_NO_ORPHANS: 1
  } {
    bun ...$rest
  }
}

# Find the root package.json from
export def find-root-package [
  dir?: path
]: [nothing -> path] {
  mut path = $dir | default { pwd }
  loop {
    try {
      let packageJsonPath = $path | path join 'package.json'
      if 'workspaces' in (open -r $packageJsonPath | from json) {
        log info $'Found root package: ($packageJsonPath)'
        return $packageJsonPath
      }
    }
    let nextPath = $path | path dirname
    if $nextPath == $path { break }
    $path = $nextPath
  }
  error make -u { msg: $'No package.json with workspaces found from (pwd)'}
  return
}

export def add-to-catalog [
  catalog: string
  ...pkgs: string
]: [oneof<nothing, string, list<string>> -> string] {
  let rootPackageJson = find-root-package

  let pkgsToVersions = $in
    | append $pkgs
    | each -f { if '{' in $in {$in | str expand} else $in }
    | api npm get
    | each { {$in.name: $in.version} }
    | into record
    | tee { log info -R $in }

  open $rootPackageJson
  | upsert $.workspaces.catalogs { default {} }
  | upsert ($.workspaces.catalogs | cell-path join $catalog) {
      default {} | merge $pkgsToVersions
    }
  | save -f $rootPackageJson

  $pkgsToVersions
  | items {|name| $'"($name)": "catalog:($catalog)",' }
  | str join (char newline)
  | tee { try { pbcopy } }
}

export def run --wrapped [...rest] {
  if ($rest | is-empty) {
    open ./package.json | $in.scripts
  } else {
    run-external bun run ...$rest
  }
}

export def g [] {
  cd ~/.bun/install/global
  bun pm ls
}

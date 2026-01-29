use ./npm.nu
use ./utils/log.nu

export def find-root-package []: [nothing -> path] {
  mut path = pwd
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
    | npm api
    | each { {$in.name: $in.version} }
    | into record
    | tee { log info -r $in }

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

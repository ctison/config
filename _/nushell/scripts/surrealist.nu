use ./gh
use ./utils/log.nu

export def update []: nothing -> nothing {
  let v = try {
    open /Applications/Surrealist.app/Contents/Info.plist
    | get CFBundleShortVersionString
  } catch { 'N/A' }

  log info $'Current version: ($v)'

  let latestRelease = gh release latest surrealdb/surrealist

  $latestRelease
  | get tag_name
  | parse -r 'v(\d+(\.\d+){2})'
  | get capture0.0
  | tee { log info $'Latest version: ($in)' }
  | if $in != $v {
    log info $'New version detected: ($v) -> ($in)'
    loop {
      match (input 'Install (y/n): ') {
        'y' => {
          $latestRelease | install
          break
        }
        'n' => { break }
      }
    }
  }

  ignore
}

export def install [--keep(-k)]: record -> nothing {
  let tmp = mktemp -d

  let url = $in
    | get assets
    | where name ends-with .dmg and name =~ $nu.os-info.arch
    | first
    | get browser_download_url

  let out = $tmp
    | path join ($url | url parse | get path | path basename)

  http get -r $url | save -frp $out

  log info $'Downloaded release: ($out)'

  hdiutil attach $out
  cp -rfv /Volumes/Surrealist/Surrealist.app /Applications/
  hdiutil detach /Volumes/Surrealist

  if not $keep {
    rm -rf $out
  }

  ignore
}

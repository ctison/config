export def 'ext version' [pkg: string] {
  {
    "filters": [
      {
        "criteria": [
          { "filterType": 8, "value": "Microsoft.VisualStudio.Code" },
          { "filterType": 10, "value": $pkg }
        ],
        "pageNumber": 1,
        "pageSize": 100,
        "sortBy": 0,
        "sortOrder": 0
      }
    ],
    "assetTypes": [],
    # https://github.com/microsoft/vscode-docs/issues/6006#issuecomment-1695686756
    "flags": (0 bit-or 0x200) # latest-only
  }
  | http * -M POST -t application/json -H {
    Accept: 'application/json;api-version=7.2-preview.1'
  } https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery $in
  | $in.results.extensions.0.0
}

export def 'ext download' [
  pkg: string
  --version: string
  --path(-p): path = '.'
] {
  mkdir $path
  let platform = ((uname).kernel-name | str downcase)-((uname).machine | str replace 'aarch64' 'arm64')
    | log debug { $'$platform: ($in)' }
  let ext = cache api-vscode-ext-($pkg) { ext version $pkg }
  let file = $path | path join $'($pkg)-($ext.versions.0.version).vsix'
    | log debug { $'$file: ($in)' }

  if ($file | path exists) {
    log info { $'Skipping ($file)' }
    return
  }

  let others = glob ($pkg)-*.vsix

  $ext | (http * -H {
      Accept: 'application/json;api-version=7.2-preview.1'
    } ('https://marketplace.visualstudio.com/_apis/public/gallery/publishers/'
      + ($in.publisher.publisherName)
      + /vsextensions/($in.extensionName)/
      + ($in | let _in | try {
          $in.versions
          | where targetPlatform? == $platform
          | $in.0.version
        } catch {|err|
          $_in.versions.0.version
        })
      + /vspackage
      + (if $platform in $in.versions.targetPlatform? {
          $'?targetPlatform=($platform)'
        } else '')
      | log debug -f
    ) # cSpell:words vsextensions vspackage
  )
  | save -p $file
  log info { $'Extension downloaded: ($file)' }

  log info { $'Deleting: ($others)' }
  rm -f ...$others

  null
}

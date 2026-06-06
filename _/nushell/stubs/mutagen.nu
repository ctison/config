@complete external
export def --wrapped 'sync create' [...rest] {
  do -i { git ls-files -o --directory -i --exclude-standard e> /dev/null }
  | lines
  | each {$'--ignore=/($in)'}
  | log debug -f { $'`mutagen sync` ignores: ($in | describe)' }
  | log debug -fR { $in }
  | mutagen sync create ...$in ...$rest
  | ignore
}

export def --wrapped 'sync list' [
  --raw(-R)
  ...rest
] {
  mutagen sync list --template '{{ json . }}' ...$rest
  | from json
  | if $raw { $in } else {
    select mode name status alpha.path beta.path
  }
}

export def --wrapped 'sync prune' [...rest] {
  sync list -R
  | where status == connecting-beta
  | if ($in | is-not-empty) or ($rest | is-not-empty) {
    mutagen sync terminate ...$rest ...$in.identifier
  }
}

export def --wrapped 'forward list' [
  --raw(-R)
  ...rest
] {
  mutagen forward list --template '{{ json . }}' ...$rest
  | from json
  | if $raw { $in } else {
    select status source.endpoint destination.host
  }
}

export def --wrapped 'forward prune' [...rest] {
  forward list -R
  | where status == connecting-destination
  | if ($in | is-not-empty) or ($rest | is-not-empty) {
    mutagen forward terminate ...$rest ...$in.identifier
  }
}

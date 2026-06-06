@complete external
export def --wrapped main [...rest] {
  swift ($cfg.DIR_ | path join swift deeplinks.swift) ...$rest
}

export def --wrapped ls [
  --raw(-R)
  ...rest
] {
  main ls ...$rest
  | from json
  | if $raw { $in } else {
    select appId appName appPath scheme
  }
}

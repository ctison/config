@complete external
export def --wrapped main [...rest] {
  swift ($cfg.DIR_ | path join swift dns.swift) ...$rest
}

@complete external
export def --wrapped main [...rest] {
  swift ($cfg.DIR_ | path join swift default-handlers-urls.swift) ...$rest
}

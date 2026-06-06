@complete external
export def --wrapped main [...rest] {
  with-env {
    CODEX_HOME: $'($cfg.DIR_)/codex'
    CLAUDE_CONFIG_DIR: $'($cfg.DIR_)/claude'
  } {
    ^code ...$rest
  }
}

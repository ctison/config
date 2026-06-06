@complete external
export def --wrapped main [...rest] {
  with-env {
    CLAUDE_CONFIG_DIR: $'($cfg.DIR_)/claude'
  } {
    ^claude ...$rest
  }
}

export def --wrapped ask [...rest] {
  {
    # outputStyle: ''
  }
  | to json -r
  | (
    main --settings $in
    --bare --print --no-session-persistence
    --permission-mode plan
    --max-budget-usd 0.50
    # --plugin-dir
    # --system-prompt-file
    ...$rest
  )
}

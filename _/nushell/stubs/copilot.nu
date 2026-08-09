@complete external
export def --wrapped main [...rest] {
  with-env {
    COPILOT_HOME: ($cfg.DIR_)/copilot
  } {
    copilot ...$rest
  }
}

export def research [] {
  ls -a ~/.copilot/session-state/*/research/*.md
  | update name {
    str replace -r $'^($env.HOME | str escape-regex)' '~'
    | fmt link $in
  }
}

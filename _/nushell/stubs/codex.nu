@complete external
export def --wrapped main [...rest] {
  with-env {
    CODEX_HOME: $'($cfg.DIR_)/codex'
  } {
    (bun x --bun -p @openai/codex codex
      ...(if ($rest | is-empty) {[--strict-config]} else [])
      ...$rest
    )
  }
}

export def --wrapped ask [...rest] {
  main exec -p ask --strict-config --skip-git-repo-check ...$rest
}

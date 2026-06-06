@complete external
export def --wrapped main [...rest] {
  with-env {
    RIPGREP_CONFIG_PATH: null
  } {
    (rg
      # https://docs.rs/regex/1.*/regex/#syntax
      # https://docs.rs/regex/1.*/regex/bytes/index.html#syntax
      # -P: https://www.pcre.org
      --hidden
      --glob=!.git/
      --no-require-git
      --type-not=lock
      ...$rest
    )
  }
}

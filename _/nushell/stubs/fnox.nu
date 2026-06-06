@complete external
export def --wrapped main [...rest] {
  with-env {
    FNOX_CONFIG_DIR: ($cfg.DIR_)/fnox
  } {
    fnox ...$rest
  }
}

export def run [profile: string, closure: closure] {
  with-env (
    main -P $profile export -f json
    | from json
    | $in.secrets
  ) $closure
}

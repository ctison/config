@complete external
export def --wrapped main [...rest] {
  with-env {
    GIT_CONFIG_SYSTEM: /dev/null
    GIT_CONFIG_GLOBAL: ($cfg.DIR_)/git/config
  } {
    (
      git -c include.path=($cfg.DIR_)/git/sign.config
      ...$rest
    )
  }
}

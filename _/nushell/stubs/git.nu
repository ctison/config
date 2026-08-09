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

@complete external
export def --wrapped status [...rest] {
  main status --porcelain=v1 ...$rest
  | lines
  | parse -r '^(?<stage>.)(?<change>.) (?<path>.+)$'
  | update stage { if $in != ' ' { $in } }
  | update change { if $in != ' ' { $in } }
}

export alias s = status

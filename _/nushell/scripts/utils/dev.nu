use ./cfg.nu

export def main [...rest] {
  # let id = job spawn {
    ^watchexec -w $cfg.DIR_NU -e .nu --only-emit-events
  # }
}

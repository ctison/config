use ./log.nu

export def main [
  --log-level(-l): string@'log complete-log-level'
  --login(-f)
] {
  log with-log-level --level=$log_level {
    log info $'Reloading with (log get-current-log-level)'
    if ($login) {
      exec login -lfq $env.USER
    } else {
      exec $nu.current-exe
    }
  }
}

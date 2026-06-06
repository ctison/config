def rl [--log-level(-l): string, --login] {
  log info $'Reloading with (log current-log-level)'
  log with-log-level ($log_level | default -e { log current-log-level }) {
    if ($login) {
      exec login -lfq $env.USER
    } else {
      with-env {
        __RELOAD: (state | to json --raw)
        __COMMANDLINE: (commandline)
      } {
        if (has-tool nu) {
          exec nu
        } else {
          exec $nu.current-exe
        }
      }
    }
  }
}

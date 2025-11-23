export const ENV_LOG_VAR_NAME = 'XYZ_LOG'

export const LOG_LEVELS = [trace debug info warning error]

const LOG_LEVELS_PRECEDENCES = {
  trace: 0
  debug: 1
  info: 2
  warning: 3
  error: 4
}

const LOG_LEVELS_COLORS = {
  trace: (ansi blue_reverse)
  debug: (ansi blue_bold)
  info: (ansi green_bold)
  warning: (ansi yellow_bold)
  error: (ansi red_bold)
}

export def main [
  # Return all log levels: list<string>
  --list(-l)
  # Return $env var name: string
  --env-var-name(-e)
]: nothing -> oneof<string, table> {
  if ($list) {
    return $LOG_LEVELS
  }
  if ($env_var_name) {
    return $ENV_LOG_VAR_NAME
  }
  scope modules | where name == log | transpose
}

def nu-complete-log-level []: nothing -> list<string> { $LOG_LEVELS }

export def --env set-log-level [level: string@nu-complete-log-level]: nothing -> nothing {
  load-env {
    $ENV_LOG_VAR_NAME: $level
  }
}

export def get-current-log-level []: nothing -> string {
  $env | get -o $ENV_LOG_VAR_NAME | default info
}

def should-print [level: string@nu-complete-log-level]: nothing -> bool {
  return (
    ($LOG_LEVELS_PRECEDENCES | get $level)
      >= ($LOG_LEVELS_PRECEDENCES | get (get-current-log-level))
  )
}

export def colorize [
  level: string@nu-complete-log-level
  msg: string
]: nothing -> string {
  $'(ansi reset)($LOG_LEVELS_COLORS | get $level)($msg)(ansi reset)'
}

export def format [
  level: string@nu-complete-log-level
  ...rest: any
  --raw(-r)
  --force(-f)
]: nothing -> nothing {
  if ($force) or (should-print $level) {
    if ($raw) {
      print ...$rest
    } else {
      print $'(colorize $level ($level | str upcase)): ($rest | get -o 0 | debug)' ...($rest | skip 1)
    }
  }
}

export alias trace = format trace
export alias debug = format debug
export alias info = format info
export alias warning = format warning
export alias error = format error

use ./fmt.nu
use ./state.nu

const ENV_KEY = '__LOG_LEVEL'
const STATE_KEY = $.log_level

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

export def complete-log-level []: nothing -> list<string> { $LOG_LEVELS }

export def get-current-log-level []: nothing -> string { state get -o $STATE_KEY | default info }

export def --env set-log-level [level: string@complete-log-level]: nothing -> nothing {
  $level | state set $STATE_KEY | ignore
}

export def --env toggle-debug [] {
  set-log-level (if (get-current-log-level) != 'debug' {'debug'} else 'info')
}

def should-print [level: string@complete-log-level]: nothing -> bool {
  return (
    ($LOG_LEVELS_PRECEDENCES | get $level)
      >= ($LOG_LEVELS_PRECEDENCES | get (get-current-log-level))
  )
}

export def colorize [
  level: string@complete-log-level
  msg: string
]: nothing -> string {
  $'(ansi reset)($LOG_LEVELS_COLORS | get $level)($msg)(ansi reset)'
}

export def format [
  level: string@complete-log-level
  ...rest: any
  --raw(-r)
  --force(-f)
]: nothing -> nothing {
  if $force or (should-print $level) {
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

export def with-log-level [
  --level(-l): string@complete-log-level
  closure: closure
] {
  with-env {
    $ENV_KEY: ($level | default {get-current-log-level})
  } $closure
}

export def --env scope [
  --debug (-d)
  file: string
  --fn: string
  closure?: closure
  --enter
  --exit
]: nothing -> any {
  let file = fmt link $file
  let log = if $debug == true or $fn in [null export-env] {
    {|msg| debug $msg}
  } else {
    {|msg| trace $msg}
  }
  let fn = if ($fn != null) {fmt fn $fn} else ''
  if $closure != null or $enter {
    do $log $'>>> Loading ($file) ($fn)'
  }
  let result = if ($closure != null) {
    $in | do --env $closure
  }
  if $closure != null or $exit {
    do $log $'<<< Exiting ($file) ($fn)'
  }
  $result
}

use ./cfg.nu DIR_NU
const self = path self

export-env {
  scope $self --fn load-env {
    $env | get -o $ENV_KEY | if $in != null {
      set-log-level $in
    }
    hide-env -i $ENV_KEY
  }
}

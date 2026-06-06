
const ENV_KEY = '__LOG_LEVEL'
const STATE_KEY = $.log-level
export const LOG_LEVELS = [trace debug info warning error]
const LOG_LEVELS_PRECEDENCES = {
  trace: 0
  debug: 1
  info: 2
  warning: 3
  error: 4
}
const LOG_LEVELS_STYLES = {
  trace: blue_reverse
  debug: blue_bold
  info: green_bold
  warning: yellow_bold
  error: red_bold
}
const LOG_LEVELS_COLORS = {
  trace: (ansi $LOG_LEVELS_STYLES.trace)
  debug: (ansi $LOG_LEVELS_STYLES.debug)
  info: (ansi $LOG_LEVELS_STYLES.info)
  warning: (ansi $LOG_LEVELS_STYLES.warning)
  error: (ansi $LOG_LEVELS_STYLES.error)
}

# Nu completer for log level enum
export def complete-log-level [] {
  {
    completions: (
      $LOG_LEVELS | each {
        let level
        { value: $level, style: ($LOG_LEVELS_STYLES | get $level) }
      }
    )
  }
}

# Returns the current log level
export def current-log-level []: nothing -> string {
  state get -o $STATE_KEY | default info
}

# Returns true if current log level is "debug", false otherwise
export def is-debug []: nothing -> bool { (current-log-level) == 'debug' }

# Set the current log level
export def --env set-log-level [level: string@"complete-log-level"]: nothing -> nothing {
  $level | state set $STATE_KEY { $in } | ignore
}

# Set the current log level to "debug" if not in, else set it to "info"
export def --env toggle-debug [] {
  set-log-level (if (current-log-level) != 'debug' { 'debug' } else 'info')
}
def should-print [level: string@"complete-log-level"]: nothing -> bool {
  return (
    ($LOG_LEVELS_PRECEDENCES | get $level)
      >= ($LOG_LEVELS_PRECEDENCES | get (current-log-level))
  )
}

# Colorize the given $msg by the given $level
export def colorize [level: string@"complete-log-level", msg: string]: nothing -> string {
  $'(ansi reset)($LOG_LEVELS_COLORS | get $level)($msg)(ansi reset)'
}

# Print the $msgs if $level is above `(log current-log-level)`
export def main [
  level: string@complete-log-level
  ...msgs: oneof<closure, string>
  --raw(-R)   # Do not colorize the $msgs
  --force(-f) # Force printing no matters the log level
]: any -> any {
  let _in
  | tee {
    let msgs = $msgs | default -e { [$_in] }
    if $force or (should-print $level) {
      for msg in $msgs {
        match ($msg | describe) {
          closure => { $_in | do $msg }
          _ => ($msg | table -e)
        }
        | if $raw {
          print
        } else {
          print $'(colorize $level ($level | str upcase)): ($in)'
        }
      }
    }
  }
}

# Run a closure with given $level
export def with-log-level [level: string@"complete-log-level", closure: closure] {
  with-env { $ENV_KEY: $level } $closure
}
export def --env scope [
  file: string
  closure?: closure
  --debug(-d)
  --fn: string
  --enter
  --exit
]: nothing -> any {
  let file = fmt link $file
  let log = if $debug == true or $fn in [null export-env] {
    {|msg| main debug $msg }
  } else {
    {|msg| main trace $msg }
  }
  let fn = if $fn != null { fmt fn $fn } else ''
  if $closure != null or $enter { do $log $'>>> Loading ($file) ($fn)' }
  let result = if $closure != null { $in | do --env $closure }
  if $closure != null or $exit {
    do $log $'<<< Exiting ($file) ($fn)'
  }
  $result
}
const SELF = path self
export-env {
  scope $SELF --fn load-env {
    $env | get -o $ENV_KEY | if $in != null {
      set-log-level $in
    }
    hide-env -i $ENV_KEY
  }
}

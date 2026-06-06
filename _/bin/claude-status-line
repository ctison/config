#!/usr/bin/env -S nu --stdin

# https://code.claude.com/docs/en/statusline

def main [] {
  from json
  | let json
  | [
    (
      $'vscode://file($json.transcript_path)'
      | ansi link -t $'($json.session_name)'
      | $'(ansi xterm_indianreda)(ansi bo)($in)'
    )
    ($'(ansi xterm_lightsalmon1)($json.model.id) ($json.effort.level)'
      + (if $json.fast_mode { $'(ansi xterm_indianredb) [fast]' } else '')
      + (if $json.thinking?.enabled == false { $'(ansi xterm_indianredb) [no thinking]' } else '')
    )
    $'(ansi xterm_grey53)($json.context_window.used_percentage)%'
    $'(ansi xterm_lightgoldenrod2b)($json.context_window.current_usage.input_tokens) (char upwards_arrow)'
    $'(ansi xterm_lightgoldenrod2b)($json.context_window.current_usage.cache_creation_input_tokens) (char hamburger)'
    $'(ansi xterm_lightgoldenrod2b)($json.context_window.current_usage.cache_read_input_tokens) (char high_voltage_sign)'
    $'(ansi xterm_lightgoldenrod2b)($json.context_window.current_usage.output_tokens) (char downwards_arrow)'
    ...(
      if $json.rate_limits? != null {
        [
          $'(ansi xterm_grey53)($json.rate_limits?.five_hour.used_percentage)% 5h'
          $'(ansi xterm_grey53)($json.rate_limits?.seven_day.used_percentage)% 1w'
        ]
      } else []
    )
  ]
  | where ($in | is-not-empty)
  | str join $'(ansi dark_gray_bold) · '
  | print
}

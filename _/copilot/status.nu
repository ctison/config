#!/usr/bin/env -S nu --stdin

def main [] {
  # $in
  # | save -f ~/.copilot/status-stdin.json
  $in
  | from json
  | let json
  | $'vscode://file($json.transcript_path)/events.jsonl' | ansi link -t $json.session_id
  | fill -a Center -w ((term size).columns - 2)
  | $'(ansi reset)($in)(ansi reset)'
  | print
}

#!/usr/bin/env -S nu --stdin

def main [] {
  from json | let json
  $json.tool_input?.file_path?
  | if $in != null {
    mise x -- bun --bun prettier --write --ignore-unknown $in
    mise x -- bun --bun biome check --write --no-errors-on-unmatched --reporter=summary $in
  }
  return
}

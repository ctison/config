export def main [tool: string]: nothing -> bool {
  which -a $tool | where type == external | is-not-empty
}

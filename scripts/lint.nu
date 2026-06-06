def main [] {
  main fmt
  main biome
  main cspell
}

def 'main fmt' [...rest] {
  git ls-files --cached --others --exclude-standard
  | lines
  | where {$in | path exists}
  | ls ...$in
  | where type == file
  | $in.name
  | bun --bun prettier --check --ignore-unknown ...$in
}

def --wrapped 'main biome' [...rest] {
  bun --bun biome ci --reporter=summary ...$rest
}

def --wrapped 'main cspell' [...rest] {
  bun --bun cspell .
}

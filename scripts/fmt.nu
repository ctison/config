def main [] {
  git ls-files --cached --others --exclude-standard
  | lines
  | where { $in | path exists }
  | ls ...$in
  | where type == file
  | $in.name
  | bun --bun prettier --write --ignore-unknown ...$in
}

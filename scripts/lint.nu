# Run the repo-wide format & lint sweep.
def main [] {
  git ls-files --cached --others --exclude-standard
  | lines
  | where { $in | path exists }
  | ls ...$in
  | where type == file
  | $in.name
  | tee { where $in == package.json | bun --bun sort-package-json --check ...$in }
  | tee { bun --bun prettier --check --ignore-unknown ...$in }
  | tee { where $in ends-with .toml | bun --bun tombi format --check ...$in }
  | tee { bun --bun biome ci --reporter=summary ...$in }
  null
}

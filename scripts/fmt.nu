# Format all tracked & untracked files with prettier (and tombi for TOML).
def main [] {
  ($env.FILE_PWD)/../_/mise/conf.d/config.toml
  | let config
  | open $config
  | update tools ($in.tools | sort)
  | update tool_alias ($in.tool_alias | sort)
  | save -f $config

  git ls-files --cached --others --exclude-standard
  | lines
  | where { $in | path exists }
  | ls ...$in
  | where type == file
  | $in.name
  | tee { where $in == package.json | bun --bun sort-package-json ...$in }
  | tee { bun --bun prettier --write --ignore-unknown ...$in }
  | tee { where $in ends-with .toml | bun --bun tombi format ...$in }

  null
}

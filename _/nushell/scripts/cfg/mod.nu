export module ./cache.nu
export use ./doc.nu
export use ./fmt.nu
export use ./log.nu
export module ./preview.nu
export module ./mise.nu
export module ./state.nu

export const DIR = path self | path expand | path dirname -n 4
export const DIR_NU = path self | path expand | path dirname -n 3
export const DIR_BIN = $DIR | path join bin/

export def main [--raw(-r) --expand(-e)]: nothing -> oneof<table, string> {
  doc --module=cfg --raw=$raw --expand=$expand
}

export def --env set-env [update: record, --level(-l) = trace]: nothing -> nothing {
  for $it in ($update | items {|k v| [$k $v]}) {
    $it.1 | table -e | if ($in | lines | length) > 1 {
      log format $level ($'$env.($it.0)' | fmt var) $in
    } else {
      log format $level $'($'$env.($it.0)' | fmt var) = ($in)'
    }
    load-env {$it.0: $it.1}
  }
}

export def --env if-tool-run [tool:string code:closure]: nothing -> nothing {
  if (which $tool | is-empty) {
    log warning $'(fmt tool-not-found $tool)'
  } else do --env $code
}

export def --env 'path add' [paths: list<string>]: nothing -> nothing {
  for $path in $paths {
    if ($path | path type) == dir {
      log debug $'$env.PATH ++ (fmt link $path)'
      load-env {
        PATH: ($env.PATH ++ [$path])
      }
    } else {
      log trace $'Path ($path) not found'
    }
  }
  load-env {
    PATH: ($env.PATH | uniq)
  }
}

# do {
#   # Remove broken symlinks
#   let path = $nu.default-config-dir | path split
# }

# # Add missing symlinks
# for $f in (ls -as $CONFIG_DIR_NU | get name) {
#   let target = $nu.default-config-dir | path join $f
#   let source = $CONFIG_DIR_NU | path join $f
#   if ($target | path type) != symlink {
#     ln -sv $source $target
#   }
# }

# # Fix broken symlinks
# for $f in (ls -af $nu.default-config-dir | where type == symlink | $in.name) {
#   if not ($f | path exists) {
#     ls $f | print
#     rm -i $f
#   }
# }

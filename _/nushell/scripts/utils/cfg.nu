export const DIR = path self | path expand | path dirname -n 4
export const DIR_NU = path self | path expand | path dirname -n 3
export const DIR_CONFIG = $DIR | path dirname
export const DIR_X = $DIR_CONFIG | path dirname
export const DIR_BIN = $DIR | path join bin/

const SELF = path self
const DIR_SELF = $SELF | path dirname

export def update-__sources [dir: path = $DIR_SELF] {
  glob ($dir | path join **/*.nu)
  | each {path relative-to $dir}
  | where {$in not-in [__source.nu log.nu]}
  | sort
  | each {$'use ./($in)'}
  | str join (char newline)
  | ["use ./log.nu\n" $in '']
  | str join "\n"
  # | save -f ($DIR_SELF | path join __source.nu)
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

export const DIR_GIT = $cfg.DIR_X | path join x

export def main [repo?: string]: [nothing -> nothing] {
  $repo
  | default {
    %ls -tf ~/x/x
    | where type == dir
    | %ls -lt --du ...$in.name
    | where type == dir
    | select name size accessed modified
    | sort-by -r accessed
    | update name { path relative-to $DIR_GIT }
    | input list
    | $in.name
  }
  | url parse -b https://github.com
  | let url | log info { $'$url: ($in | url join)' }
  | $DIR_GIT
  | path join ($url.path | str replace -r ^/* '')
  | let dir | log info { $'$dir: ($in)' }
  | if not ($dir | path exists) {
    (git clone
      --depth 20
      ($url | url join) $dir
    )
  }
}

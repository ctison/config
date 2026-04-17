use ./cfg.nu DIR_CONFIG
use ./log.nu

export const DIR_CACHE = $DIR_CONFIG | path join x/.cache

export def main [
  key: string
  closure: closure
  --ttl: duration = 1day
]: nothing -> any {
  let ttl = $ttl | default 1day
  let path = $DIR_CACHE | path join $key
  mkdir ($path | path dirname)
  if ($path | path exists) {
    open $path
    | from nuon
    | if (((date now) - $in.lastUpdate) < $ttl) {
      log debug $'Cache hit from ($path)'
      $in.data
    } else {
      main run $path $closure
    }
  } else {
    main run $path $closure
  }
}

def 'main run' [
  path: string
  closure: closure
]: nothing -> any {
  log debug $'Cache reload at ($path)'
  do $closure
  | {
    lastUpdate: (date now)
    data: $in
  }
  | tee {
    to nuon
    | save -f $path
    }
  | $in.data
}

export def 'list' []: nothing -> table {
  %ls -a ($'($DIR_CACHE)/**/*' | into glob) | where type != dir
}

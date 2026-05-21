use ./cfg.nu DIR_STATE_GLOBAL
use ./log.nu

export const DIR_CACHE = $DIR_STATE_GLOBAL | path join .cache

# Cache to filesystem the return value of a closure
export def main [
  # Key of the cached value
  key: string
  # Closure to run to renew the cached value
  closure: closure
  # Time to live of the cached value
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

# Internal. Run the closure and save results to path.
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

# List the cached files holding the cached values
export def 'list' []: nothing -> table {
  %ls -a ($'($DIR_CACHE)/**/*' | into glob) | where type != dir
}

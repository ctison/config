export def init [
  --cpus: int = 5
  --disk-size: int = (64gib / 1gib)
  --memory: int = (8gib / 1mib)
  --now = true
  --volumes: list<path> = [($cfg.DIR_X):($cfg.DIR_X)]
] {
  (^podman machine init
    --cpus $cpus
    --disk-size $disk_size
    --memory $memory
    ...(if $now {[--now]} else [])
    --volume (
      $volumes
      | default {
        [($cfg.DIR_X):($cfg.DIR_X)]
      }
      | to json -r
      | str replace -ar '["]' ''
    )
  )
}

@complete external
export def --wrapped ls [...rest] {
  (^podman machine ls
    --format json
    --all-providers
    ...$rest
    | from json
  )
}

# TODO: generate nushell wrapping functions:
# - `info` for `podman machine info --format json ...$rest | from json`
# - `inspect` for `podman machine inspect --format json ...$rest | from json`
# - `start`
# - `stop`

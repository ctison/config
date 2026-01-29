use ../utils/log.nu
use ./docker.nu

const LABEL_APP = $.'dev.app'
const LABEL_CWD = $.'dev.cwd'

export def help [cmd: string = 'start']: nothing -> string {
  ^docker run -it --rm surrealdb/surrealdb $cmd --help
  | collect
  | ^bat -l help
}

export def start []: nothing -> any {
  let db = ls -c
  match ($db | length) {
    0 => {
      mkdir .data
      log info 'Starting surrealdb'
      let id = (
        ^docker run --rm -d -p 8000
        -l x-app=surrealdb,x-cwd=(pwd)
        --mount=type=bind,src=.data,dst=/x
        -e SURREAL_NO_BANNER=true
        -e SURREAL_LOG_FILE_ENABLED=true
        -e SURREAL_LOG_FILE_PATH=/x
        -e SURREAL_SLOW_QUERY_LOG_THRESHOLD=1ns
        # -e SURREAL_LOG=debug
        # -e SURREAL_CAPS_DENY_ALL=true
        -e SURREAL_USER=admin
        -e SURREAL_PASS=admin
        surrealdb/surrealdb
        start surrealkv:/x/db.surreal
        --allow-experimental
        --allow-all
      )
      ls -c | table -c | log info -r $in
    }
    1 => {
      if $db.0.state == paused {
        ^docker start $db.name
      }
    }
    $n if $n > 1 => {
      error make -u {msg: $'Found ($n) containers matching'}
    }
  }
}

export def ls [--current(-c)]: nothing -> table {
  ps
  | where state != dead
  | where labels.x-app? == surrealdb
  | if not $current { $in } else {
    $in
    | where labels.x-cwd? == (pwd)
  }
}

export def logs [--follow(-f)]: nothing -> string {
  ls -c
  | $in.0.name
  | tee {print}
  | ^docker logs ...(if $follow {['-f']} else []) $in
}

export def stop [--force(-f)]: nothing -> string {
  ls -c
  | if ($in | is-not-empty) {
    log info $'Stopping containers: ($in.name)'
    ^docker stop ...($in.name)
    $in | if $force {
      ^docker rm ...($in.name)
    }
  }
}

export def restart [--force(-f)]: nothing -> any {
  stop --force=($force)
  start
}

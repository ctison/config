use ../utils/log.nu
use ./docker.nu

const LABEL_APP = $.'dev.app'
const LABEL_CWD = $.'dev.cwd'

export def help [cmd: string = 'start']: nothing -> string {
  ^docker run -it --rm surrealdb/surrealdb $cmd --help
  | collect
  | ^bat -l help
}

export def pull []: nothing -> nothing {
  ^docker pull surrealdb/surrealdb
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
  update-surrealist
  update-dotenv
}

export def update-surrealist []: nothing -> nothing {
  ls -c
  | $in.ports.0.0
  | parse -r ':(?<port>\d+)->'
  | $in.port.0
  | let port
  let name = pwd | path basename
  let url = $'127.0.0.1:($port)'
  try { killall surrealist o+e>/dev/null }
  let configPath = '~/Library/Application Support/SurrealDB/Surrealist/config.json' | path expand
  open $configPath
    | update $.connections {
      let _name = $'🐳 ($name)'
      $in | match ($in | any {|e| $e.name == $_name}) {
        true => {
          update $.authentication.hostname $url
        }
        false => {
          append {
            "authentication": {
              "access": "",
              "accessFields": [],
              "database": "",
              "hostname": $url,
              "mode": "root",
              "namespace": "",
              "password": "admin",
              "protocol": "ws",
              "token": "",
              "username": "admin"
            },
            "designerTableList": true,
            "diagramAlgorithm": "default",
            "diagramDirection": "default",
            "diagramHoverFocus": "default",
            "diagramLineStyle": "default",
            "diagramLinkMode": "default",
            "diagramMode": "default",
            "diagramStrategy": "NETWORK_SIMPLEX",
            "explorerTableList": true,
            "graphqlQuery": "",
            "graphqlShowVariables": false,
            "graphqlVariables": "{}",
            "icon": 24,
            "id": (random chars -l 8),
            "labels": [ "local" ],
            "lastDatabase": $name,
            "lastNamespace": $name,
            "name": $_name,
            "pinnedTables": [],
            "queries": [],
            "queryHistory": [],
            "queryTabList": true
          }
        }
      }
    }
    | save -f $configPath
  ^open -a Surrealist
  ignore
}

export def update-dotenv []: nothing -> nothing {
  ls -c
  | $in.ports.0.0
  | parse -r ':(?<port>\d+)->'
  | $in.port.0
  | let port
  if ('.env.local' | path exists) {
    open -r .env.local
    | str replace -m '^(SURREAL_ENDPOINT)=.*$' $'$1=ws://127.0.0.1:($port)'
    | save -f .env.local
    log info 'Updated .env.local'
  }
  ignore
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

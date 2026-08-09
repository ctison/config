export const DIR_STATE = $cfg.DIR_STATE_LOCAL | path join surrealdb
export const NAME = 'surrealdb'
export const IMAGE = 'surrealdb/surrealdb'
export const VERSION = 'latest'
const SELECT = [x-cwd x-port]

export use ./_docker.nu *

export def start []: nothing -> any {
  let c = ls -cR
  match ($c | length) {
    0 => {
      mkdir $DIR_STATE
      log info 'Starting surrealdb'
      let id = (
        docker run --rm -d -p 8000
        -l x-app=($NAME),x-cwd=(pwd)
        --mount=type=bind,src=($DIR_STATE),dst=/x
        -e SURREAL_NO_BANNER=true
        -e SURREAL_LOG_FILE_ENABLED=true
        -e SURREAL_LOG_FILE_PATH=/x
        -e SURREAL_SLOW_QUERY_LOG_THRESHOLD=1ns
        # -e SURREAL_LOG=debug
        # -e SURREAL_CAPS_DENY_ALL=true
        -e SURREAL_USER=admin
        -e SURREAL_PASS=admin
        ($IMAGE):($VERSION)
          start surrealkv:/x/db.surreal
          --allow-experimental
          --allow-all
      )
      ls -c | %table -e | log debug -Rf
    }
    1 => {
      if $c.0.state == paused {
        log info $'Starting container ($c.name)'
        docker start $c.name
      }
    }
    $n if $n > 1 => {
      error make -u { msg: $'Found ($n) containers matching' }
    }
  }
  update-dotenv
  update-surrealist
}

export def update-dotenv []: nothing -> nothing {
  ls -cR
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

export def update-surrealist []: nothing -> nothing {
  ls -cR
  | $in.ports.0.0
  | parse -r ':(?<port>\d+)->'
  | $in.port.0
  | let port
  let name = pwd | path basename
  let url = $'127.0.0.1:($port)'
  let shouldStartSurrealist = ps | where name == surrealist | is-not-empty
  try { killall surrealist o+e> /dev/null }
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
  if $shouldStartSurrealist {
    ^open -a Surrealist
  }
  ignore
}

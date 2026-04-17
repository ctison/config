use ../utils/log.nu
use ../utils/cache.nu
use ./docker.nu
use ./api.nu
use ../utils/cfg.nu DIR_CONFIG

const DIR_DATA = $DIR_CONFIG | path join x/.docker/elk

const LABEL_APP = $.'dev.app'
const LABEL_CWD = $.'dev.cwd'

export def get-latest []: nothing -> record<kibana: string, elasticsearch: string> {
  {
    kibana: (api repos tags library kibana | $in.0.name)
    elasticsearch: (api repos tags library elasticsearch | $in.0.name)
    apm-server: (api repos tags -s elastic apm-server | $in.0.name)
  } | tee {log info $'($in)'}
}

export def pull []: nothing -> nothing {
  let tags = get-latest
  ^docker pull kibana:($tags.kibana)
  ^docker pull elasticsearch:($tags.elasticsearch)
  ^docker pull elastic/apm-server:($tags.apm-server)
}

# https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-docker-basic

export def start [--force(-f)]: nothing -> any {
  let tags = get-latest

  mkdir $DIR_DATA

  if $force {
    try { ^docker rm -f kibana elasticsearch apm-server o+e> /dev/null }
  }

  if (docker ps | where name == elasticsearch | is-empty) {
    rm -f ($DIR_DATA)/password ($DIR_DATA)/enrollment-token-kibana
  }

  try { ^docker network create elk o+e> /dev/null }
  log info "Created network 'elk'"

  if (docker ps | where name == elasticsearch | length) == 0 {
    (^docker run -d --name elasticsearch
      --network elk
      -m 1GB
      -p 127.0.0.1:9200:9200
      elasticsearch:($tags.elasticsearch)
    )
    log info 'Started elasticsearch on https://127.0.0.1:9200'
  }

  let password = try {
    open -r ($DIR_DATA)/password
    | tee { http head -u elastic -p $in -k https://127.0.0.1:9200 }
    | tee { log debug 'Restored password from cache' }
  } catch {
    mut password = ''
    for i in 0..5 {
      if  $i == 5 {
        error make {msg: $'Failed to connect to elasticsearch [tried ($i) times]'}
      }
      log debug $'Sleeping ($i)sec'
      sleep ($'($i)sec' | into duration)
      $password = try {
        (^docker exec -it elasticsearch
          bash -c 'echo y | elasticsearch-reset-password -u elastic')
        | lines
        | last
        | parse 'New value: {password}'
        | $in.password.0
        | str trim
        | if ($in | is-empty) { error make } else $in
        | tee { http head -u elastic -p $in -k https://127.0.0.1:9200 }
        | tee { save -f ($DIR_DATA)/password }
      } catch {
        continue
      }
      break
    }
    $password
  }

  http head -u elastic -p $password -k https://127.0.0.1:9200
  log info $'Password: ($password)'


  if (docker ps | where name == kibana | length) == 0 {
    let token = try {
      open -r ($DIR_DATA)/enrollment-token-kibana
    } catch {
      ^docker exec -t elasticsearch bash -c 'elasticsearch-create-enrollment-token -s kibana'
      | str trim
      | tee { save -f ($DIR_DATA)/enrollment-token-kibana }
    }

    log info $'Enrollment token for kibana: ($token)'
    (^docker create --name kibana
      --network elk
      -p 127.0.0.1:5601:5601
      kibana:($tags.kibana)
    )
    let tmpDir = mktemp -d
    ^docker cp kibana:/usr/share/kibana/config/kibana.yml $tmpDir
    # cSpell:words xpack authc
    { xpack.security.authc.providers.anonymous.a1: {
      order: 0,
      credentials: { username: 'elastic', password: $password },
    }} | $'(char newline)($in | to yaml)' | save -a ($tmpDir)/kibana.yml
    chmod 666 ($tmpDir)/kibana.yml
    ^docker cp ($tmpDir)/kibana.yml kibana:/usr/share/kibana/config/kibana.yml
    ^docker start kibana
    ^docker exec -it kibana kibana-setup -t $token
    ^docker restart kibana
    log info 'Started kibana on http://127.0.0.1:5601'
  }

  if (docker ps | where name == apm-server | length) == 0 {
    (^docker create --name apm-server
      --network elk
      -p 127.0.0.1:8200:8200
      elastic/apm-server:($tags.apm-server)
      -e --strict.perms=false
    )
    let tmpDir = mktemp -d
    {
      apm-server.host:'0.0.0.0:8200'
      output.elasticsearch: {
        hosts: ['elasticsearch:9200']
        protocol: https
        username: elastic
        password: $password
        ssl.verification_mode: none
      }
    }
    | to yaml
    | save -f ($tmpDir)/apm-server.yml
    chmod 444 ($tmpDir)/apm-server.yml
    ^docker cp ($tmpDir)/apm-server.yml apm-server:(docker inspect apm-server | $in.Config.WorkingDir)/apm-server.yml
    rm -rf ($tmpDir)
    docker start apm-server
    log info 'Started apm-server on 127.0.0.1:8200'
  }

  ignore
}

export def 'kibana otp' [] {
  ^docker exec -it kibana kibana-verification-code
}

export def stop [--rm] {
  if $rm {
    ^docker rm elasticsearch kibana apm-server
  } else {
    ^docker stop elasticsearch kibana apm-server
  }
}

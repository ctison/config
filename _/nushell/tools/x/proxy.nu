# Install and trust a .crt to containers
export def 'install certs' [
  ...crts: list<path>
] {
  default -e {
    docker ps
    | input list -m
    | $in.name
  }
  | each {
    let containerName
    $crts
    | default -e {
      glob ($cfg.DIR_STATE_GLOBAL)/.certs/*.crt
    }
    | each {
      let crt
      try {
        log info $'Copying ($crt) to ($containerName):/usr/local/share/ca-certificates/'
        docker cp $crt ($containerName):/usr/local/share/ca-certificates/
      } catch { log warning -R }
      log info $'Running `update-ca-certificates` inside ($containerName)'
      docker exec -it $containerName /bin/bash -c 'update-ca-certificates'
      | print
    }
  }
  null
}

export def main [] {
  $env
  | select -o HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy NODE_EXTRA_CA_CERTS
}

export def --env set [
  upstream: string
  --noProxy: list<string>
] {
  load-env {
    HTTP_PROXY: $upstream
    HTTPS_PROXY: $upstream
    NO_PROXY: $noProxy
    http_proxy: $upstream
    https_proxy: $upstream
    no_proxy: $noProxy
    NODE_EXTRA_CA_CERTS: ($cfg.DIR_STATE_GLOBAL | path join .certs ca.crt)
  }
}

export def --env unset [] {
  hide-env -i HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy NODE_EXTRA_CA_CERTS
}

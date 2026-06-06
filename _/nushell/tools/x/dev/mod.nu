export const NAME = 'dev'
export const IMAGE = 'ghcr.io/ctison/dev'
export const VERSION = 'latest'
const SELECT = [x-cwd x-port]

export use ../_docker.nu *
export use ./build.nu

export def main [
  --name(-n): string
  --image(-i): string = $IMAGE
  --x-app: string = $NAME
  --no-vcs
  ...rest
]: nothing -> nothing {
  let name = $name | default {
    pwd
    | path basename
    | str replace --regex  '[ \.]' '-'
    | $'($in)'
  }

  docker ps
  | where name == $name
  | if ($in | is-not-empty) {
    $in.0
    | match $in.state {
      running => {
        (alacritty msg create-window
          --hold
          -T $'[DOCKER - ($in.name)]'
          -e (which -a docker | where type == external).0.path # docker
          attach --detach-keys=ctrl-_,ctrl-_ $name
        )
        return
      }
    }
  }

  let mounts = []

  log info { $'Starting container' }
  (alacritty msg create-window
    --hold
    -T $'[DOCKER - ($name)]'
    -e (which -a docker | where type == external).0.path # docker
      run -it --rm --name $name --hostname $name
      -l x-app=($x_app),x-cwd=(pwd)
      -e GITHUB_TOKEN=(fnox -P dev get GITHUB_TOKEN)
      ...$mounts
      --network dev
      --workdir $'/root/($name)'
      -v codex-($name):/root/.codex
      -v mise-cache:/root/.local/share/mise/downloads
      -v bun-cache:/root/.bun/install/cache
      -v vscode-exts:/vscode-exts
      -v code-server-exts:/root/.local/share/code-server/extensions/
      $image
      ...(if $image == $IMAGE {[
        zellij options
          --session-name $name
          --default-shell nu
      ]} else [])
      ...$rest
  )

  log info { $'Waiting container creation' }
  docker events --format json --since ((date now) - 1sec | format date %s)
  | from json -o
  | generate {|event, acc=null|
    if ($event.Type == container
      and $event.Action == create
      and $event.Actor.Attributes.name == $name) {
      $event | log debug -fR
      {}
    } else {next: null}
  }

  # Mutagen sessions' names must not have: _
  let sessionName = $name | str replace -ar _ -

  log info { $'Syncing (pwd)' }
  (mutagen sync create -n $sessionName -m two-way-safe
      ...(if $no_vcs {[--ignore-vcs]} else [])
      (pwd) $'docker://($name)/root/($name)'
  )
  mutagen sync list | where name == $sessionName | print

  do {
    log info { $'Syncing /config' }
    cd $cfg.DIR_
    (mutagen sync create -n ($sessionName)-config -m one-way-replica --ignore-vcs
      $cfg.DIR_ $'docker://($name)/config/_'
    )
    mutagen sync list | where name == ($sessionName)-config | print
  }

  log info { $'Syncing codex authn' }
  (mutagen sync create -n ($sessionName)-codex -m one-way-replica
    ($cfg.DIR_)/codex/auth.json $'docker://($name)/root/.codex/auth.json')

  log info { $'Installing system certs' }
  [$name] | proxy install certs ...(glob ($cfg.DIR_STATE_GLOBAL)/.certs/*.crt)

  # log info { $'Exposing code-server' }
  # let codeServerPort = port
  # (mutagen forward create -n ($sessionName)-code-server
  #   tcp:127.0.0.1:($codeServerPort) docker://($name):tcp:localhost:($code_server.PORT)
  # )

  # log info { $'Starting code-server' }
  # let tabId = (docker exec -it $name
  #   mise x --silent -- zellij ac new-tab --name code-server -- nu -e 'code-server start'
  # )
  # docker exec -it $name mise x --silent -- zellij ac move-tab --tab-id $tabId left

  # # docker exec -it $name mise x -- nu ln -svf /config/_/vscode/favicon.* ~/.local/share/code-server/
  # print ''
  # $'http://localhost:($codeServerPort)'
  # | tee { log info $'code-server: ($in)' }
  # | ^open $in
}


export use ./tmp.nu

const LABEL = 'x-app=tmp'
const DEFAULT_IMAGE = 'ctison/dev'

export def main [
  --name(-n): string
  --image(-i): string = $DEFAULT_IMAGE
  ...rest
]: nothing -> nothing {
  let name = $name | default {
    pwd | path basename | str replace --regex  '[ \.]' '-' | $'dev-($in)'
  }
  let mounts = []

  (docker run -itd --rm --name $name --hostname $name -l 'x-app=tmp'
    -e GITHUB_TOKEN=(fnox -P dev get GITHUB_TOKEN)
    ...$mounts --workdir $'/root/($name)' $image ...$rest
  )

  do -i { git ls-files -o --directory -i --exclude-standard e>/dev/null }
  | lines | each {$'--ignore=/($in)'}
  | log debug $'Mutagen ignore flags: ($in)'
  | (mutagen sync create -n $name -m two-way-safe --ignore-vcs ...$in
      (pwd) $'docker://($name)/root/($name)'
    )

  (mutagen sync create -n $'($name)-config' -m one-way-replica --ignore-vcs
    $cfg.DIR_ $'docker://($name)/config/_'
  )

  if (has-tool alacritty) and (has-tool docker) {
    (alacritty msg create-window
      -T $'[DOCKER - ($name)]'
      -e (which -a docker | where type == external).0.path attach $name)
  } else {
    docker attach $name
  }
}

export def ls []: nothing -> table {
  docker ps
  | where $in.labels.x-app? == tmp
}

export def rm [] {
  ls
  | input list -m
  | docker rm -f ...($in.name)
}

export def build [
  --arch(-a): string
  --pull(-p)         # pull base image
  --no-cache         # no cache
  --debug(-d)
]: nothing -> nothing {
  let arch = $arch | default { $'linux/(uname | $in.machine)' }
  (^fnox run -P github
      docker build --platform $arch
        ...(if $pull {[--pull]} else [])
        ...(if $debug {[--debug]} else [])
        ...(if $no_cache {[--no-cache]} else [])
        --secret type=env,id=GITHUB_TOKEN
        --load -t ctison/dev $cfg.DIR_ROOT
  )
}

export def tmp [
  --name(-n): string
  --rm
  --image: string = $DEFAULT_IMAGE
  ...rest
]: nothing -> nothing {
  let tmpDir = mktemp -dp $cfg.DIR_STATE_DOCKER tmp-(date now | format date '%y-%m-%d')-XXX
  log info $'Created temporary directory: ($tmpDir)'
  cd $tmpDir
  main --name $name --image $image ...$rest
  cd -
  if ($rm) {
    %rm -rf $tmpDir
  }
}

export def 'tmp ls' [] {
  %ls ($'($cfg.DIR_STATE_DOCKER)/tmp-*' | into glob)
}

export def run [] {
  docker run -it --rm ctison/dev
}

use ../utils/log.nu
use ../utils/cfg.nu

export def main [
  --name(-n): string
  image?: string
  ...rest
]: nothing -> nothing {
  let image = $image | default -e { 'ctison/dev' }
  let name = $name | default {
    pwd | path basename | str replace ' ' '-' | str replace '.' '-' | $'dev-($in)'
  }
  let mounts = []

  (docker run -it --rm -d --name $name --hostname $name
    ...$mounts --workdir $'/root/($name)' $image ...$rest
  )

  do -i { git ls-files -o --directory -i --exclude-standard e>/dev/null }
  | lines | each {$'--ignore=/($in)'}
  | log debug $'Mutagen ignore flags: ($in)'
  | (mutagen sync create -n $name -m two-way-safe --ignore-vcs ...$in
      (pwd) $'docker://($name)/root/($name)'
    )

  docker attach $name

  mutagen sync terminate $name
}

export def build [--arch(-a): string, --pull(-p), --debug(-d)]: nothing -> nothing {
  use ../utils/cfg.nu
  let arch = $arch | default { $'linux/(uname | $in.machine)' }
  (^fnox run -P github
      docker build --platform $arch
        ...(if $pull {[--pull]} else [])
        ...(if $debug {[--debug]} else [])
        --secret type=env,id=GITHUB_TOKEN
        --load -t ctison/dev $cfg.DIR_ROOT
  )
}

export def ls [] {
  mutagen sync list
}

export def tmp [
  --name(-n): string
  --rm
  image?: string
  ...rest
]: nothing -> nothing {
  let tmpDir = mktemp -dp $cfg.DIR_STATE_DOCKER tmp-(date now | format date '%y-%m-%d')-XXX
  log info $'Created temporary directory: ($tmpDir)'
  cd $tmpDir
  main --name $name $image ...$rest
  cd -
  if ($rm) {
    rm -rf $tmpDir
  }
}

export def 'tmp ls' [] {
  %ls ($'($cfg.DIR_STATE_DOCKER)/tmp-*' | into glob)
}

export def run [] {
  docker run -it --rm ctison/dev
}

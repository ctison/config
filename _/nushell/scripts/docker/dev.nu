export def main [
  --name (-n): string
  ...rest
]: nothing -> nothing {
  let name = $name | default {pwd | path basename | str replace ' ' '-'}
  let mounts = []

  (docker run -it --rm -d --name $name --hostname $name
    ...$mounts --workdir $'/root/($name)' ...$rest
  )

  git ls-files -o --directory -i --exclude-standard
  | lines | each {$'--ignore=/($in)'}
  | (mutagen sync create -n $name -m two-way-safe --ignore-vcs ...$in
      (pwd) $'docker://($name)/root/($name)'
    )

  docker attach $name

  mutagen sync terminate $name
}

export def build [--arch(-a): string, --pull(-p), --debug(-d)]: nothing -> nothing {
  use ../utils/cfg.nu
  let arch = $arch | default { $'linux/(uname | $in.machine)' }
  (docker build --platform $arch
    ...(if $pull {[--pull]} else [])
    ...(if $debug {[--debug]} else [])
    --load -t ctison/dev $cfg.DIR_CONFIG)
}

export def run [] {
  docker run -it --rm ctison/dev
}

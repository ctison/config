use ../log
use ../cfg

export def ops [
  --image (-i): string = 'ctison/dev'
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

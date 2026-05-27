export def --wrapped 'docker ps' [
  --filter(-F): closure
  --raw(-R)
  ...rest
] {
  ^docker ps --all --format=json --no-trunc # cSpell:ignore trunc
  | from json -o
  | rename -b { str kebab-case }
  | rename -c { names: name, created-at: created }
  | update created { date from-human }
  | update labels {
    split row -r ','
    | each { split row '=' }
    | where ($in | length) == 2
    | into record
  }
  | update local-volumes { into int }
  | update mounts { split row ',' }
  | update ports { split row -r ', *' | compact -e | if ($in | is-empty) {''} else $in }
  | update running-for? { try {
      str replace -r 'About ' '' | date from-human
    } catch { $in }
  }
  | update size { into filesize }
  | move --first state name image ports created
  | if $filter != null { do $filter } else $in
  | if $raw { $in } else {
    select state name image created
  }
}

export def --wrapped 'docker attach' [
  --detach-keys: string = 'ctrl-_,ctrl-_'
  # https://man.archlinux.org/man/docker-container-attach.1.en#Override_the_detach_sequence
  ...rest
] {
  ^docker attach --detach-keys=($detach_keys) ...$rest
}

export def 'docker inspect' [nameOrId: string]: nothing -> record {
  ^docker inspect -f json $nameOrId
  | from json
  | first
}

export def --wrapped 'docker diff' [
  --raw(-R)
  ...rest
] {
  if ($rest | length) == 0 {
    [ (docker ps | input list).name ]
  } else $rest
  | ^docker diff ...$in
}

export def 'docker images' [
  --raw(-R)
] {
  ^docker images -a --format json --no-trunc
  | from json -o
  | rename -b { str downcase }
  | update size { into filesize }
  | update createdsince { date from-human }
  | if $raw { $in } else {
    select repository tag size createdsince
  }
}


export def 'docker logs' [container?: string] {
  $container
  | default { docker ps | input list | $in.name }
  | ^docker logs $in
}

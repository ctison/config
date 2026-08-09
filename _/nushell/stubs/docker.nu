export def --wrapped 'docker ps' [
  --filter(-F): closure
  --select(-S): list<string>
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
    select state name image created ...$select
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
  | rename -b { str lowercase }
  | update size { into filesize }
  | update createdsince { try { date from-human } catch { $in } }
  | if $raw { $in } else {
    select repository tag size createdsince
  }
}

export def 'docker logs' [container?: string] {
  $container
  | default { docker ps | input list | $in.name }
  | ^docker logs $in
}

export def 'docker volume ls' [
  --raw(-R)
] {
  ^docker volume ls --format json
  | from json -o
  | if $raw { $in } else {
    $in
  }
}

export def 'docker volume inspect' [
  --raw(-R)
] {
  ^docker volume inspect --format json
  | from json
  | if $raw { $in } else {
    $in
  }
}

export def --wrapped 'docker rmi' [...rest] {
  append $rest
  | if ($in | is-empty) {
    docker images
    | input list -m
    | each {|row| ($row.repository):($row.tag) }
  }
  | if ($in | is-not-empty) { ^docker rmi ...$in }
}


export def --wrapped 'docker stop' [...rest] {
  append $rest
  | if ($in | is-empty) {
    docker ps
    | input list -m
    | $in.name?
  }
  | if ($in | is-not-empty) { ^docker stop ...$in }
}

@complete external
export def --wrapped 'docker network ls' [...rest] {
  ^docker network ls --format json --no-trunc
  | from json -o
  | update CreatedAt { into datetime -f '%F %T%.9f %z %Z' }
  | update IPv4 { into bool }
  | update IPv6 { into bool }
  | update Internal { into bool }
  | move --first Name
}


@complete external
export def --wrapped 'docker port' [name: string, ...ports: string] {
  if $ports != [] {
    $ports
    | each -f {
      ^docker port $name $in
      | parse -r '^(?<address>[^:]*):(?<port>\d+)$'
    }
  } else {
    ^docker port $name
    | parse -r '^(?<containerPort>\d+)/(?<protocol>\w+) -> (?<address>[^:]*):(?<port>\d+)$'
  }
}

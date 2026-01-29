export def ps []: nothing -> table {
  ^docker ps --all --format=json --no-trunc # cSpell:ignore trunc
  | from json -o
  | rename -b { str kebab-case }
  | rename -c {names: name, created-at: created}
  | update created { date from-human }
  | update labels { split row ',' | each {split row '='} | into record }
  | update local-volumes { into int }
  | update mounts { split row ',' }
  | update ports { split row -r ', *' | compact -e | if ($in | is-empty) {''} else $in }
  | update running-for? { try {
      str replace -r 'About ' '' | date from-human
    } catch { $in }
  }
  | update size { into filesize }
  | move --first state name image ports created
}

export def inspect [nameOrId: string]: nothing -> record {
  docker inspect -f json $nameOrId
  | from json
  | first
}

export def ls [app?: string] {
  docker ps
}

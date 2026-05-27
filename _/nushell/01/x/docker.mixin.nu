export def pull []: nothing -> nothing {
  docker pull $IMAGE
}

export def --wrapped help [...rest] {
  docker run -it --rm $IMAGE ...$rest --help o+e>| collect
  | bat -l help --paging always
}

export def ls [
  --current(-c)
  --raw(-R)
]: nothing -> table {
  docker ps --raw
  | where state != dead
  | where labels?.x-app? == $NAME
  | if not $current { $in } else {
    where labels.x-cwd? == (pwd)
  }
  | insert x-app {|row| $row.labels.x-app }
  | insert x-cwd {|row|
    $row.labels.x-cwd?
    | if ($in | is-not-empty) {
      try {
        [~ ($in | path relative-to ~)] | path join
      } catch {
        $in
      }
    }
  }
  | insert x-port {|row|
    $row.ports.0?
    | if ($in | is-not-empty) {
      do --ignore-errors {
        split row '->'
        | $in.0
        | split row :
        | $in.1
      }
    }
  }
  | if $raw { $in } else {
    select x-app name ...$SELECT state created image
  }
}

def _select_container [
  --multi(-m)
  closure: closure
  notFound?: closure
] {
  ls -R
  | let ls
  | if ($in | length) == 0 {
    if $notFound != null {
      return (do $notFound)
    } else {
      log info $'No container found'
    }
    return
  }

  $ls
  | if ($in | length) == 1 {
    return ($in | do $closure)
  }

  $ls
  | where labels.x-cwd? == (pwd)
  | let current
  | if ($in | length) == 1 {
    return ($in | do $closure)
  }

  $ls
  | select name x-app x-cwd image state created
  | input list --multi=($multi) --index
  | [$in] | flatten
  | let indexes

  $ls
  | enumerate
  | where $it.index in $indexes
  | $in.item
  | [$in] | flatten | do $closure
}

export def logs [] {
  _select_container { docker logs $in.name.0 }
}

export def stop [] {
  _select_container {
    $in.name
    | log info { $'Stopping containers: ($in)' }
    | docker stop ...$in
  }
}

export def rm [--force(-f)] {
  _select_container {
    $in.name
    | log info { $'Deleting containers: ($in)' }
    | docker rm ...(if $force {[--force]} else []) ...$in
  }
}

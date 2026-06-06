export use ./surreal.nu
export use ./proxy.nu
export use ./caido.nu
export use ./dev
export use ./open.nu

export def ls [] {
  docker ps -R
  | where state != dead
  | insert x-app {|row| $row.labels.x-app? }
  | insert x-cwd {|row|
    $row.labels.x-pwd?
    | if $in != null { path relative-to-home } else $in
  }
  | insert x-port {|row|
    if ($row.ports | is-empty) { return }
    $row.ports.0?
    | if ($in | is-not-empty) {
      do --ignore-errors {
        (split row '->').0 | (split row :).1
      }
    }
  }
  | select x-app name x-cwd x-port state created image
  | tee {
    $in.x-port
    | each {
      $'http://localhost:($in)'
      | print
    }
  }
  | table -e
  | print

  mutagen sync prune
  mutagen sync list
  | if ($in | is-not-empty) { table -e | print }

  mutagen forward prune
  mutagen forward list
  | if ($in | is-not-empty) { table -e | print }
}

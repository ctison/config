export def main [--page(-p) = 1]: [nothing -> table] {
  gh api $'/notifications?page=($page)' | from json
}

export def read [...ids: string]: [oneof<nothing, list<string>> -> nothing] {
  append $ids
  | par-each { gh api -X PATCH $'/notifications/threads/($in)' }
  null
}

export def done [...ids: string]: [oneof<nothing, list<string>> -> nothing] {
  append $ids
  | par-each { gh api -X DELETE $'/notifications/threads/($in)' }
  null
}

export def drain [
  --file(-f): path
  # Max pages to fetch
  --max-pages: int = 512
]: [nothing -> nothing] {
  let file = $file | default {
    $'gh-notifs-(date now | date to-timezone utc | format date '%F_%T').json'
  }
  if ($file | path exists) {
    log error $'File exists and would be overwritten: ($file)'
    return
  }
  log info $'Output file: ($file)'
  mut notifs = []
  for i in 1.. {
    log info $'Fetching page ($i)'
    if $i > $max_pages { break }
    let n = notifs
    if ($n | is-empty) { break }
    $notifs ++= $n
    $notifs | save -f $file
    $n.id | notifs done
  }
  log info $'Done fetching ($notifs | length) notifications'
  null
}

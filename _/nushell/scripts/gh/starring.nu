export def main [--file(-f): path]: nothing -> nothing {
  if ($file | path exists) {
    log error $'File exists and would be overwritten: ($file)'
    return
  }
  log info $'Output file: ($file)'

  mut watching = []
  for i in 1.. {
    log info $'Fetching page ($i)'
    let w = gh api $'/user/starred?per_page=100&page=($i)' | from json
    if ($w | is-empty) { break }
    $watching ++= $w
    $watching | save -f $file
  }
  log info $'Done fetching ($watching | length) watched repos'
  null
}

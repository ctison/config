alias nu-table = table

export def main [] {
  scope modules | where name == preview | transpose | nu-table -e
}

export def table []: [table -> nothing] {
  let data = $in
  for $theme in (nu-table --list) {
    print $'(ansi xterm_red1)(ansi bo)($theme)(ansi reset)'
    $data | nu-table --theme $theme | print
  }
}

use ./fmt.nu

alias nu-table = table

export def main [] {
  scope modules | where name == preview | transpose | nu-table -e
}

export def table [lang?: string]: table -> nothing {
  let data = $in | collect
  for $theme in (nu-table --list | input list -m) {
    fmt -ba [xterm_red1] $theme | print
    $data | nu-table --theme $theme | print
  }
}

export def bat [lang?: string]: any -> nothing {
  let data = $in | collect
  for $theme in (
    ^bat --list-themes | lines | str replace -r ' \(default.*\)$' '' | input list -m
  ) {
    fmt -ba [xterm_red1] $theme | print
    $data | ^bat --theme $theme --color=always --file-name $theme --paging always ...(
      if ($lang != null) {[$'--language=($lang)']} else []
    )
  }
}

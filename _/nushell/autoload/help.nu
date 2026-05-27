def h [
  --find(-f): string
  ...rest
] {
  if ($find | is-not-empty) {
    help -f $find ...$rest
    | table -e
    | bh --color=never --paging=auto
    | return $in
  }
  $in | if ($rest | is-empty) {
    $in | bh
    return
  }
  let which = which $rest.0
  if ($which | is-not-empty) {
    if $which.0.definition? != null {
      h ...($which.0.definition | split row ' ') ...($rest | slice 1..)
    } else if (
        $which.0.type == 'external'
        or $which.0.type == custom
        and (scope commands | where name == $rest.0 | $in.0.complete == 'external')
      ) {
      run-external ...$rest '--help' o+e>| h
    } else {
      help ...$rest
      | bh --color=never
    }
  } else {
    help ...$rest
    | bh --color=never
  }
}

alias nu-help = help
alias help = h

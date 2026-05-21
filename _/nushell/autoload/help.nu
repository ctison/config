alias nu-help = help

def help [
  --find(-f): string
  ...rest
] {
  if ($find | is-empty) and ($rest | is-empty) {
    if ($in | is-empty) { error make }
    $in | bh
    return
  }
  if $find != null {
    nu-help --find=($find) ...$rest
  } else if (
    (which $rest.0 | where type == 'custom' | is-not-empty)
    and (scope commands
      | where name == $rest.0 and complete == 'external'
      | is-not-empty)
  ) {
    run-external ...$rest '--help' | bh
    return
  } else {
    nu-help ...$rest
  }
  | bh --color=never
}

def h [
  --find(-f): string
  ...rest
] {
  if ($find | is-not-empty) {
    help -f $find ...$rest
    return
  }
  let which = which -a $rest.0
  if ($which | is-not-empty) and $which.0.type == 'external' {
    run-external ...$rest '--help' o+e>| bh
  } else {
    help ...$rest | table -e | bh --color=never
  }
}

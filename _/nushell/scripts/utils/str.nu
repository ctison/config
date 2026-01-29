export def dedent []: string -> string {
  let lines = $in | lines
  let regex = $lines | each {split chars -g} | reduce -f null {|line acc|
    match ($line | length) {
      0 => $acc
      _ => {
        $line | take until {$in != ' '} | length
        | if $acc == null or $in < $acc {$in} else $acc
      }
    }
  } | $'^ {($in)}'
  $lines | each {str replace -r $regex ''} | str join (char newline)
}

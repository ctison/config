export def main [
  --any(-a): list<string>
  --bold(-b)
  --dimmed(-d)
  --hidden(-h)
  --italic(-i)
  --newline(-n)
  --underline(-u)
  --reverse(-r)
  --strike(-s)
  --double_underline(-w)
  msg?: string
]: oneof<nothing, string> -> string {
  let msg = $in | default $msg
  if ($msg == null) {
    [
      [flag                                               preview];
      ['--any=[blue]         -a' ((main -a [blue] NUSHELL) + ' is fine')]
      ['--bold               -b' ((main -b NUSHELL) + ' is fine')]
      ['--dimmed             -d' ((main -d NUSHELL) + ' is fine')]
      ['--italic             -i' ((main -i NUSHELL) + ' is fine')]
      ['--underline          -u' ((main -u NUSHELL) + ' is fine')]
      ['--reverse            -r' ((main -r NUSHELL) + ' is fine')]
      ['--hidden             -h' ((main -h NUSHELL) + ' is fine')]
      ['--strike             -s' ((main -s NUSHELL) + ' is fine')]
      ['--double_underline   -w' ((main -w NUSHELL) + ' is fine')]
    ] | table | print
    return
  }
  $'([
    (if $any != null      {($any | each {ansi $in} | str join)})
    (if $bold             {(ansi attr_bold)})
    (if $dimmed           {(ansi attr_dimmed)})
    (if $italic           {(ansi attr_italic)})
    (if $underline        {(ansi attr_underline)})
    (if $reverse          {(ansi attr_reverse)})
    (if $hidden           {(ansi attr_hidden)})
    (if $strike           {(ansi attr_strike)})
    (if $double_underline {(ansi attr_double_underline)})
  ] | str join
  )($msg)([
    (if $any != null      {(ansi reset)})
    (if $bold             {(ansi reset_bold)})
    (if $dimmed           {(ansi reset_dimmed)})
    (if $italic           {(ansi reset_italic)})
    (if $underline        {(ansi reset_underline)})
    (if $reverse          {(ansi reset_reverse)})
    (if $hidden           {(ansi reset_hidden)})
    (if $strike           {(ansi reset_strike)})
    (if $double_underline {(ansi reset_underline)})
    (if $newline          {(char newline)})
  ] | str join
  )'
}

export def link [path: path]: nothing -> string {
  $'file://($path | path expand -n)' | ansi link --text $path | main -a [light_gray_bold]
}

export def tool-not-found [tool?: string]: oneof<nothing, string> -> string {
  $'command not found: (default $tool | main -a [light_red_bold])'
}

export def var [name?: string]: oneof<nothing, string> -> string {
  default $name | main -b
}

export def fn [name?: string]: oneof<nothing, string> -> string {
  default $name
  | $in + (if $in == 'export-env' {'{}'} else '()')
  | main -a [purple_bold]
}

export def error [
  payload: record<msg: string, label: string, span: record<start: int, end: int>>
]: nothing -> error {
  error make {
    msg: (main -na [red_bold] $payload.msg)
    label: {text: $payload.label, span: $payload.span}
  }
}

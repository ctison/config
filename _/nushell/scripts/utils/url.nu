export def 'make query' [--test]: [oneof<record, nothing> -> string] {
  if $test {
    use std/assert
    assert equal ({a: null, b: 42, c: 'cd'} | make query) '?b=42&c=cd'
    assert equal ({} | make query) ''
    assert equal ({a: null, b: null} | make query) ''
    return
  }
  $in
  | if $in == null { return '' } else $in
  | items {|k v| if ($v | is-not-empty) {[$k $v]}}
  | into record
  | url build-query
  | if ($in | is-not-empty) { $'?($in)' } else ''
}

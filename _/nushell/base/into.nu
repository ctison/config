# === Bucket ====

export def bucket [--default: string = '␀']: list<any> -> record {
  reduce -f {} {|it acc|
    $acc | upsert ($it | default $default) {
      default 0 | $in + 1
    }
  }
}

# === Trie ====

def _trie [fragments: list<string>] {
  if ($fragments | length) == 0 {
    return $in
  } else $in
  | upsert $fragments.0 {
    default { {} }
    | _trie ($fragments | slice 1..)
  }
}
export def trie []: list<list<string>> -> record {
  reduce -f {} {|it acc|
    $acc | _trie $it
  }
}
export def 'trie from urls' []: list<string> -> record {
  par-each {
    url parse
    | [$in.host ...($in.path | path split)]
    | main
  }
}

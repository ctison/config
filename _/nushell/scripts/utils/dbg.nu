# Tee debug a value to stdout
export def main [
  # Drop the input and returns the debug
  --drop
]: any -> any {
  tee {
    match ($in | describe) {
      'closure' => ([[id source]; [($in | debug) (view source $in)]])
      _ => ($in | describe)
    }
    | if $drop { return $in }
      else { print }
  }
}

export def desc []: any -> record {
  describe -d | desc recurse
}

def 'desc recurse' []: record -> record {
  match $in.type {
    'record' => {
      update columns {
        items {|k v| [$k ($v | desc recurse)] }
        | into record
      }
    }
    'list' => {
      update value { select type value? }
    }
    _ => $in
  }
  | reject detailed_type? rust_type? origin?
  | compact
}

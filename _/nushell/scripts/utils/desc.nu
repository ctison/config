export def main []: any -> record {
  describe -d | recurse
}

def recurse []: record -> record {
  match $in.type {
    'record' => {
      update columns {
        items {|k v| [$k ($v | recurse)] }
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

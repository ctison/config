export def main [] {
  tee { format | print }
}

export def format [] {
  match ($in | describe) {
    'closure' => ([[id source]; [($in | debug) (view source $in)]])
    _ => ($in | describe)
  }
}

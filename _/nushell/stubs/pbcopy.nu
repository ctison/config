export def main [] {
  tee {
    if $nu.os-info.name == macos {
      pbcopy
    } else {
      osc copy
    }
  }
}

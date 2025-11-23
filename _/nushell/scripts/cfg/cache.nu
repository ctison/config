export def main [] {
  ls $nu.cache-dir
}

export def clear [] {
  log debug $'Clearing cache: ($nu.cache-dir)'
  rm -rf $nu.cache-dir
}

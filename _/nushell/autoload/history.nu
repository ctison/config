do {
  cd $nu.default-config-dir
  glob 'history.txt.bak.<[0-9]:1,>' | if ($in | is-not-empty) {
    rm ...$in
  }
}

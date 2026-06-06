@complete external
export def --wrapped main [...rest] {
  ^xh ...$rest user-agent:
}

export def --wrapped dl [path: path, ...rest] {
  main -d -c -o $path ...$rest
}

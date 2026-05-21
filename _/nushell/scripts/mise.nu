@complete external
export def main [...rest] {
  if (which fnox | is-not-empty) {
    fnox -P github run mise ...$rest
  } else {
    mise ...$rest
  }
}

export def help [] {
  ^mise --help
}

export def fmt [
  file: path = 'mise.toml'
] {
  let content = open $file
  let aliases = $content.tools
    | items {|k|
      ^mise tool --backend $k
      | { $k: $in }
    }
  $content
  | update tools_alias { merge $aliases }
}

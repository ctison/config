@complete external
export def --wrapped main [
  --raw(-R)
  ...rest
] {
  ^mount ...$rest
  | if $rest == [] {
    lines
    | parse -r "^(?<name>.+?) on (?<path>.+?) type (?<type>.+) \\((?<opts>.+)\\)$"
    | update opts { split row , }
    | if $raw { $in } else {
      reject opts
    }
  } else $in
}

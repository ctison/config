export def relative-to-home [
  path?: path # default to (pwd)
] {
  $path
  | default { pwd }
  | let path
  try {
    $path
    | path relative-to ~
    | [~ $in]
    | path join
  } catch {
    $path
  }
}

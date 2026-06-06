export def relative-to-home [
  path?: path # default to `$in` or `pwd`
] {
  let _in
  | $path
  | default { $_in }
  | default { pwd }
  | let path
  | try {
    $path
    | path relative-to ~
    | [~ $in]
    | path join
  } catch {
    $path
  }
}

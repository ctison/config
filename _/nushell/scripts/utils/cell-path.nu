export def join [
  ...cell_paths: cell-path
  --optional(-o)
]: [
  oneof<nothing, cell-path, list<cell-path>> -> cell-path
] {
  append $cell_paths
  | flatten
  | each { match ($in | describe) {
    'string' => ([$in] | into cell-path)
    _ => $in
  }}
  | each -f {split cell-path}
  | if ($optional) {each {update optional true}} else $in
  | into cell-path
}

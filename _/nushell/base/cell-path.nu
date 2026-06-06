# Join cell-paths
export def join [
  --optional(-o)
  ...cellPaths: cell-path
]: oneof<nothing, cell-path, list<cell-path>> -> cell-path {
  append $cellPaths
  | flatten
  | each { match ($in | describe) {
    'string' => ([$in] | into cell-path)
    _ => $in
  }}
  | each -f {split cell-path}
  | if $optional { each { update optional true } } else $in
  | into cell-path
}

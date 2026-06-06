alias nu-get = get

# Alias to `state get`
export def main []: nothing -> any { get }

# Return the value from the state at $path
export def get [...key: cell-path, --optional(-o)]: nothing -> any {
  $env.__state? | nu-get ($key | cell-path join --optional=$optional)
}

# Store $in in the state at $path, and return the previous value
export def --env set [
  key: oneof<cell-path, list<cell-path>>
  closure: closure
]: any -> any {
  $in | let _in
  let key = $key | cell-path join
  let keySpan = (ignore | metadata $key).span
  $env.__state = $env.__state? | default {}
  let previous_value = get -o $key
  mut cell_path = $. | split cell-path
  for $cell in ([$key] | flatten | each -f {split cell-path}) {
    $cell_path = $cell_path | append $cell
    $env.__state = $env.__state | upsert ($cell_path | into cell-path) { default {} }
  }
  $env.__state = $env.__state | update ($cell_path | into cell-path) (
    $_in | do $closure
  )
  $_in
}

export def --env delete [...key: cell-path]: nothing -> any {
  let key = cell-path join -o ...$key
  let previous_value = $env.__state? | nu-get -o $key
  if $key == $. {
    hide-env __state
  } else {
    $env.__state = $env.__state? | reject -o $key
  }
  $previous_value
}

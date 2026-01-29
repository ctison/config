use ./cell-path.nu
use ./fmt.nu

alias nu-get = get

export def main []: nothing -> any {
  get
}

# Return the value from the state at $path
export def get [...key: cell-path, --optional(-o)]: nothing -> any {
  $env.__state? | nu-get ($key | cell-path join --optional=$optional)
}

# Store $in in the state at $path, and return the previous value
export def --env set [ key: oneof<cell-path, list<cell-path>> value?: any ]: oneof<nothing, any> -> any {
  let key = $key | cell-path join
  let key_span = (ignore | metadata $key).span
  $env.__state = $env.__state? | default {}
  let previous_value = get -o $key
  let new_value = $in | default $value
  mut cell_path = $. | split cell-path
  for $cell in ([$key] | flatten | each -f {split cell-path} | tee {
    if ($in | length) == 0 { fmt error {
        msg: 'State key length must be at least 1'
        label: 'Key length is 0'
        span: $key_span
    }}
  }) {
    $cell_path = $cell_path | append $cell
    $env.__state = $env.__state | upsert ($cell_path | into cell-path) {default {}}
  }
  $env.__state = $env.__state | update ($cell_path | into cell-path) $new_value
  $previous_value
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

export def with-prefix [prefix: cell-path]: [
  nothing -> record<set: closure, get: closure>
] {
  {
    get: {|...key: cell-path| get $prefix ...$key}
    set: {|key: cell-path, value: any| set [$prefix ...$key] $value}
    delete: {|...key: cell-path| delete $prefix ...$key}
  }
}

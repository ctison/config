export def --env main [
  condition: oneof<bool, closure>
  closure: closure
]: any -> any {
  match ($condition | describe) {
    'closure' => {if ($in | do $condition) {do --env $closure} else $in}
    'bool' => {if $condition {do --env $closure} else $in}
  }
}

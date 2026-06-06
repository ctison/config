export def main [
  block: closure # Closure to run: { ($in | path type) == 'file' }
]: any -> any {
  let tmp = mktemp
  log debug $tmp
  $in | save -f $tmp
  mut result = null
  try {
    $result = $tmp | do -c $block
  } finally {
    rm $tmp
  }
  $result
}

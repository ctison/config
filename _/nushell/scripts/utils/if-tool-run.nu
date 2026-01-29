use ./log.nu

export def --env main [
  tool: string
  closure: closure
]: nothing -> nothing {
  if (which $tool | is-empty) {
    log warning $'(fmt tool-not-found $tool)'
  } else do --env $closure
}

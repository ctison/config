$env.config.hooks.display_output = {
  if ($in | describe) == nothing { return } else $in
  | state set last-value { $in }
  | table -e
}

def o [] { state get last-value }

$env.config.hooks.pre_prompt ++= [{
  if $env.ZELLIJ_PANE_ID? != null {
    zellij ac rename-tab (path relative-to-home)
  }
  overlay list | enumerate | flatten
  | where active and name != zero and index != 0
  | if ($in | length) > 0 {
    $env.NU_OVERLAYS = $in | get name | str join ','
  }
  log current-log-level
  | if ($in != 'info') {
    $env.__LOG_LEVEL = $in
  }
}]

$env.config.hooks.pre_execution ++= [{
  hide-env -i ...[
    NU_OVERLAYS
    __LOG_LEVEL
  ]
}]

# Display current hooks
def hooks [] {
  $env.config.hooks
  | update display_output {dbg --drop}
  | update pre_prompt {each {dbg --drop}}
  | update pre_execution {each {dbg --drop}}
  | table -e
  | log info '$env.config.hooks' $in
}

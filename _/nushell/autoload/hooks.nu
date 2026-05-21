$env.config.hooks.display_output = {
  $env.__OUT = [$in]
  $in | table
}

def o [] { $env.__OUT.0 }

$env.config.hooks.pre_prompt ++= [{
  overlay list | enumerate | flatten
  | where active and name != zero and index != 0
  | if ($in | length) > 0 {
    $env.NU_OVERLAYS = $in | get name | str join ','
  }
  log get-current-log-level
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

$env.config.hooks.display_output = {
  metadata | let meta
  let value = $in
  if ($value | describe) == nothing { return } else $value
  | state set last-value { $value }
  | if $meta.select? != null { select ...$meta.select } else $in
  | table -e
}

def o [] { state get last-value }

$env.config.hooks.pre_prompt ++= [{
  if $env.ZELLIJ_PANE_ID? != null {
    if $env.ZELLIJ_PARENT_SESSION_NAME? != null {
      zellij ac list-tabs -j
      | from json
      | let tabs
      | length
      | if $in == 1 and $tabs.0.selectable_tiled_panes_count == 1 {
        zz ac rename-tab (path relative-to-home)
      }
    }
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
  # Not working, but silently ignored
  commandline edit --append ' | let o'
}]

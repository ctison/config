export def rl [...names: string]: nothing -> nothing {
  let names = $names | default -e { plugin list | $in.name }
  const BIN_DIR = $nu.current-exe | path dirname
  for name in $names {
    plugin rm $name
    plugin add ($BIN_DIR | path join $'nu_plugin_($name)')
    plugin list | print
  }
  ignore
}

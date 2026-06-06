export def up []: nothing -> nothing {
  plugin list | each {
    $in | print
    if not ($in.filename | path exists) {
      plugin rm $in.name
    }
  }

  # $env.PATH | each {
  #   do -i { fd -tx -tl ^nu_plugin_ $in | lines | each { plugin add $in } }
  # }
  null
}
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

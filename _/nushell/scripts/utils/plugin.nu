export def up []: [nothing -> nothing] {
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

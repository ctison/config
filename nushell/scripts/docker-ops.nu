export def 'docker ops' [
  --name: string = $'($env.PWD | path basename | str replace ` ` -)'
  --hostname: string
  --volume: string = $'($env.PWD):/($name):delegated'
  --workdir: string = $'/($name)'
  ...args: string
] {
  if $hostname == $nothing {
    $hostname = $name
  }

  # exec docker run -it --rm --name $name --hostname $hostname --volume $volume --workdir $workdir $args
}

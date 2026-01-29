use ./fmt.nu
use ./log.nu

export def --env add [...paths: path]: oneof<nothing, list<path>> -> nothing {
  for $path in ($in | append $paths) {
    if ($path | path expand | path type) == 'dir' {
      log debug $'$env.PATH ++ (fmt link $path)'
      $env.PATH ++= [$path]
    } else {
      log trace $'Path ($path) not found'
    }
  }
  $env.PATH = ($env.PATH | uniq)
}

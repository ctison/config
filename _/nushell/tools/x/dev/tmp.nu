export def main [
  --name(-n): string
  --rm
  --image: string
  ...rest
]: nothing -> nothing {
  let tmpDir = mktemp -dp $cfg.DIR_STATE_DOCKER main-(date now | format date '%y-%m-%d')-XXX
  log info $'Created temporary directory: ($tmpDir)'
  cd $tmpDir
  (main --name $name
    ...(if $image != null {[--image $image]} else [])
    ...$rest)
  cd -
  if ($rm) {
    %rm -rf $tmpDir
  }
}

export def ls [] {
  %ls ($'($cfg.DIR_STATE_DOCKER)/tmp-*' | into glob)
}

export def run [] {
  docker run -it --rm ctison/dev
}

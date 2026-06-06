export def reload [] {
  if (has-tool fish) {
    let fish = '~/.config/fish/completions/'
    mkdir $fish
    if (has-tool podman) {
      let dst = $fish | path join podman.fish
      if not ($dst | path exists) {
        podman completion fish | save -f $dst
      }
    }
  }
}

@complete external
export def --wrapped main [...rest] {
  with-env {

  } {
    neovim ...$rest
  }
}

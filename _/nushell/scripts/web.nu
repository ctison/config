export def map [...rest] {
  docker run -it --rm ctison/dev webclaw map ...$rest
}

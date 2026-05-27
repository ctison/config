const IMAGE = 'ghcr.io/kreuzberg-dev/kreuzberg-cli'

export def --wrapped _ [...rest] {
  docker run -it --rm $IMAGE ...$rest
}

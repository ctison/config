export def main []: nothing -> nothing {
  docker ps
  | input list
  | let container
  input 'Enter container port to expose: '
  | into int
  | let containerPort
  input 'Enter host port to expose: '
  | default -e { 0 }
  | into int
  | let hostPort
  | mutagen forward create tcp:127.0.0.1:($hostPort) docker://($container.name):tcp:localhost:($containerPort)
  null
}

export def ls []: nothing -> table {
  mutagen forward ls
}

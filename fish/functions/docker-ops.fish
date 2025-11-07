function docker-ops -w docker
  set -l name (path basename "$PWD" | string replace ' ' '-')
  docker run -it --name "$name" --hostname "$name" \
    -v "$PWD":/"$name" --workdir "/$name"
end

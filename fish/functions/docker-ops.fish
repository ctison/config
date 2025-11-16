function docker-ops -w docker
  set -l name (path basename $PWD | string replace ' ' '-')
  docker run -it --rm --name $name --hostname $name \
    --mount type=bind,src=$__CONFIG_DIR/fish/config.fish,dst=/config/fish/config.fish,ro \
    --mount type=bind,src=$__CONFIG_DIR/fish/functions,dst=/config/fish/functions,ro \
    -v $PWD:/root/$name --workdir /root/$name $argv
end

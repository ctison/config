function docker-ops -w docker
  set -l name (path basename (pwd) | string replace ' ' '-')
  set -l mounts
  pushd $__CONFIG_DIR
  for match in (rg '^ln -fsv "\$SCRIPT_DIR"/(\S+)' -or '$1' $__CONFIG_DIR/setup.sh) bin
    for file in (eval ls -d $match)
      set -a mounts --mount=type=bind,src=$__CONFIG_DIR/$file,dst=/config/$file,ro
    end
  end
  popd
  if test (count $argv) -eq 0
    set -a argv ctison/dev
  end

  docker run -it --rm -d --name $name --hostname $name \
    $mounts --workdir /root/$name $argv

  set -e mounts
  set -l ignored
  for match in (git ls-files -o --directory -i --exclude-standard)
    set -a ignored --ignore=/$match
  end

  mutagen sync create -n $name -m two-way-safe --ignore-vcs $ignored \
    (pwd) docker://$name/root/$name

  docker attach $name

  mutagen sync terminate $name
end

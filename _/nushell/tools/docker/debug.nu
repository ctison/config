const SELF = path self

export def dockerignore [] {
  let name = random chars -l 8 | str downcase
  docker build -t $name -f ($SELF | path dirname | path join Dockerfile) .
  docker run -it --rm $name
  docker rmi $name
}

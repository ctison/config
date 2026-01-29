use ../utils/log.nu

export def help [cmd: string = 'postgres']: nothing -> string {
  docker run -it --rm postgres $cmd --help
}

export def start []: nothing -> any {
  mkdir .x/postgres
  log info 'Starting postgres'
  let id = (
    docker run --rm -d -p 5432
    -l x-app=postgres,x-cwd=(pwd)
    --mount=type=bind,src=.x/postgres,dst=/var/lib/postgresql
    -e POSTGRES_USER=admin
    -e POSTGRES_PASSWORD=admin
    -e POSTGRES_DB=main
    postgres
  )
}

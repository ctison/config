use ./docker.nu

# https://github.com/swagger-api/swagger-ui/blob/HEAD/docs/usage/configuration.md

export def start [url: string]: nothing -> record {
  let id = (
    docker run --rm -d -P
    -l x-app=surrealdb,x-cwd=(pwd)
    -e URL=($url)
    swaggerapi/swagger-ui
  )
  ps | where id == $id | first
}

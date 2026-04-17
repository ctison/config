use ../utils/cache.nu

export const API_BASE_URL = 'https://hub.docker.com'

export def main []: nothing -> nothing {
  http get $'($API_BASE_URL)/v2/repositories/<namespace>/<image>/tags/'
}

export def auth []: nothing -> string {
  http post -t application/json $'($API_BASE_URL)/v2/auth/token' {
    identifier: (fnox get DOCKERHUB_USER)
    secret: (fnox get DOCKERHUB_SECRET)
  } | $in.access_token
}

export def 'repos tags' [
  ns: string, repo: string
  --raw(-r)
  # filter by semver regex
  --semver(-s)
  --ttl: duration
]: nothing -> table {
  cache --ttl=($ttl) $'dockerhub/($ns)/($repo)' {
    let accessToken = auth
    (http get
      -H {Authorization: $'Bearer ($accessToken)'}
      $'($API_BASE_URL)/v2/namespaces/($ns)/repositories/($repo)/tags?page_size=100')
    | $in.results
    | if ($semver) { where $it.name =~ '^(\d+\.){2}\d+$' } else $in
    | if ($raw) { $in } else { $in
      | select name last_updated full_size
      | update last_updated {into datetime | date humanize}
      | update full_size {into filesize}
      | sort-by -rn name
    }
  }
}

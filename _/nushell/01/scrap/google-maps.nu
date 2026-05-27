const DIR = $cfg.DIR_STATE_GLOBAL | path join google-maps

export def --wrapped _ [
  --lang = 'en'
  --radius = 10000. # in meters
  --zoom = 15
  geo: string # example: '37.7749,-122.4194'
  queries: list<string>
  ...rest
] {
  let dir = $DIR | path join (random chars --length 3)
  mkdir $dir
  log debug $dir
  $queries
  | str join (char newline)
  | save ($dir | path join queries.txt)

  try {
    # cSpell:ignore gosom
    (docker run -it --rm -v $'($dir):/data:ro'
      gosom/google-maps-scraper -json -input /data/queries.txt
        -lang $lang -radius $radius -zoom $zoom ...$rest
    )
  } finally {
    rm -rf $dir
  }
}

export def main [] {
  mkdir $DIR
  let dir = mktemp -d
}

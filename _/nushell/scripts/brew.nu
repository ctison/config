use ./utils/log.nu

export def search [
  --formula(-f)
  --cask(-c)
  ...rest: string
] {
  let formulae = if $formula or not $cask {
    ^brew search --formula ...$rest
  } else []
  let casks = if $cask or not $formula {
    ^brew search --cask ...$rest
  }
  { formulae: $formulae, casks: $casks }
  | each {$in | print}
}

export def x [
  --full(-f)
  ...rest
] {
  brew info --json ...$rest
  | from json
  | each {
    select full_name desc homepage license versions service
    | rename name desc home license versions service
    | table -e
    | print
  }
}

export def list [--raw(-R) --interactive(-i)] {
  ls /opt/homebrew/Caskroom
  | where type == dir
  | $in.name
  | path basename
  | if ($interactive) {
    input list --multi --fuzzy
  } else $in
  | if ($in | is-empty) { return } else $in
  | brew info --json=v2 --cask ...$in
  | from json
  | $in.casks
  | if (not $raw) {
    select token name desc homepage homepage url version
  } else $in
}

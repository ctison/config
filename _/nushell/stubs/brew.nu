@complete external
export def --wrapped main [...rest] {
  $env.HOMEBREW_NO_INSECURE_REDIRECT = 1
  $env.HOMEBREW_VERIFY_ATTESTATIONS = 1
  $env.HOMEBREW_NO_ANALYTICS = 1
  $env.HOMEBREW_UPGRADE_GREEDY = 1
  $env.HOMEBREW_BAT = 1
  $env.HOMEBREW_REQUIRE_TAP_TRUST = 1
  ^brew ...$rest
}

export def --wrapped info [
  --raw(-R)
  ...rest
]: nothing -> table {
  main info --json=v2 ...$rest
  | from json
  | if $raw { $in } else { info-filter }
}

def info-filter [] {
  items {|k v|
  $v
  | each {
      rename -b {
        match $in {
          full_token => 'full_name',
          _ => $in
        }
      }
      | select full_name desc homepage
      | rename name desc home
    }
    | [$k $in]
  }
  | into record
}

export def --wrapped search [
  --formula(-f)
  --cask(-c)
  ...rest: string
]: nothing -> record<formulae: record, casks: record> {
  let formulae = if $formula or not $cask {
    main search --formula ...$rest
    | split row (char newline)
  } else []
  | info ...$in
  | $in.formulae
  let casks = if $cask or not $formula {
    main search --cask ...$rest
    | split row (char newline)
  } else []
  | info ...$in
  | $in.casks

  { formulae: $formulae, casks: $casks }
}


export def list [
  --formula(-f)
  --cask(-c)
  --raw(-R)
] {
  {
    formulae: (if $formula or not $cask { ls /opt/homebrew/Cellar/ } else [])
    casks: (if $cask or not $formula { ls /opt/homebrew/Caskroom} else [])
  }
  | items {|k v|
    $v
    | where type == dir
    | $in.name
    | path basename
    | if ($in | is-empty) { return } else $in
    | info --raw=($raw) --($k) ...$in
    | get $k
    | [$k $in]
  }
  | into record
  | if $formula and not $cask {
      $in.formulae
    } else if $cask and not $formula {
      $in.casks
    } else $in
}

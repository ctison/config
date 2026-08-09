# cSpell:words npmjs

export def get [...packages: string]: [
  oneof<nothing, list<string>> -> table
] {
  append $packages | par-each -k {
    http * $'https://registry.npmjs.org/($in)/latest'
  }
}

export def user [
  user: string
  --size = 250
  --max-page: number
  --raw(-R)
] {
  0..
  | generate {|page acc=true|
    if $max_page != null and $page >= $max_page { return {} }
    (http *
      (
        $'https://registry.npmjs.org/-/v1/search?text=maintainer:($user)&size=($size)&from=($size * $page)'
        | log info $'GET ($in)'
      )
    )
    | $in.objects?
    | if ($in | is-not-empty) and ($in | describe) starts-with table {
      { out: $in, next: true }
    } else {}
  }
  | reduce -f [] {|table acc| $table ++ $acc }
  | update updated { into datetime }
  | if $raw { $in } else {
    select updated package.name package.version package.description? score.final package.links?.homepage?
  }
  | sort-by --reverse updated
}

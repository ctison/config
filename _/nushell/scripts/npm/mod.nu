export def api [...packages: string]: oneof<nothing, list<string>> -> table {
  append $packages | par-each -k {
    http get $'https://registry.npmjs.org/($in)/latest'
  }
}

export def fetch-versions [...packages: string]: oneof<nothing, list<string>> -> string {
  append $packages | api | each {
    $'"($in.name)": "($in.version)",'
  } | str join (char newline) | tee {pbcopy}
}

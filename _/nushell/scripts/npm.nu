export def api [...packages: string]: [
  oneof<nothing, list<string>> -> table
] {
  append $packages | par-each -k {
    http get $'https://registry.npmjs.org/($in)/latest'
  }
}

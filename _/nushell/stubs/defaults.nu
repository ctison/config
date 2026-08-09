export def read [domain: string]: nothing -> table {
  defaults export $domain -
  | from plist
}

export def domains []: nothing -> list<string> {
  defaults domains
  | split row ', '
  | let domains
}

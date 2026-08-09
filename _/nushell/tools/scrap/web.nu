export def main [] {

}

export def links [url: string] {
  http get --raw $url
  | regex "^https?://[A-Za-z0-9.-]+(?:/[A-Za-z0-9-._~!$&'()*+,;=:@/?%]*)?$"
  | get href
}

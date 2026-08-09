@complete external
export def source [
  --color: string = 'auto' # One of: auto always never
  item: any
] {
  %('view source') $item
  | if $color == always or $color == auto and (is-terminal --stdout) {
    nu-highlight
  } else $in
}

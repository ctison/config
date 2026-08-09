@complete external
export def --wrapped main [...rest] {
  (
    sk -c 'fd .'
      --ansi
      --color=16 --highlight-line
      --cmd-prompt '> ' --multi-selector '*'
      --tabstop 2
      --border light-triple-dashed
      ...$rest
  )
}

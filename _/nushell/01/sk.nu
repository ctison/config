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

export def --wrapped explore [...rest] {
  (
    main
      --header 'Preview files'
      --preview 'sk-preview {}'
     ...$rest
  )
}

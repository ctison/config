export def review [path: path = './cspell.yaml'] {
  open $path
  | let cSpellContent
  | $in.words
  | each {
    {
      word: $in
      count: (rg --count --glob '!**/cspell.yaml' --glob '!**/package.json' $in | lines | length)
    }
  }
  | sort-by count
  | tee { table | print }
  | input list --multi 'Would you like to remove words?'
  | if ($in | is-not-empty) {
    $in.word
    | let excludes
    $cSpellContent
    | update words { where $in not-in $excludes }
    | save -f $path
  }
}

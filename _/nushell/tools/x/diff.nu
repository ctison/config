const DIR_BASE = ($cfg.DIR_ROOT)/../base | path expand

export def main [] {
  do {
    cd $DIR_BASE
    git ls-files --cached --others --exclude-standard
  }
  | lines
  | where $in not-ends-with .lock
  | let files
  for file in $files {
    let baseFile = [$DIR_BASE $file] | path join
    if ($file | path exists) {
      delta --dark $file $baseFile
      | complete
      | $in.stdout
      | if ($in | is-not-empty) {
        bat --paging always
      }
    } else {
      loop {
        input -n 1 -s $'Create "($file)" ("(y/n)")'
        | match $in {
          y => {
            cp $baseFile $file
          }
          n => break
        }
      }
    }
  }
  null
}

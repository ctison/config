export def --env main [] {
  cd $cfg.DIR_STATE_GLOBAL
}

export def reload [
  --dry-run(-n)
  ...dirs: list<path>
] {
  $dirs
  | default -e { ls $cfg.DIR_NU | $in.name | where $in =~ '/\d\d$' }
  | each {
    let dir
    | ls -a $in
    | let ls
    | each {
      match $in {
        $d if $d.type == 'dir' and ($d.name | path join 'mod.nu' | path exists) => {
          $'use ./($in.name | path basename)'
        }
        $f if $f.name ends-with '.nu' and $f.name not-ends-with '_.nu' => {
          $'use ./($in.name | path basename)'
        }
      }
    }
    | str join (char newline)
    | [[ ($dir | path join '_.nu') ]; [ $in ]]
  }
  | reduce {|it, acc| $acc | merge $it }
  | if not $dry_run {
    tee { $in.0 | items {|path content| [$path $content] } | par-each {
      let f | $f.1 | save -f $f.0
    } }
  } else {
    log debug -f { 'DRY RUN' }
  }
  | $in.0
}

export alias rl = reload

export def 'reload mod' [
  --dry-run(-n)
  ...dirs: path
] {
  $dirs
  | each {
    let dir
    | path expand
    | path parse
    | $in.stem
    | let dirName
    | if not ($dir | path join mod.nu | path exists) {
      return
    } else $in
    | ls -a $dir
    | where ($it.name | path parse).stem != 'mod' and name ends-with '.nu' and type == file
    | each {
      if ($in.name | path parse | $in.stem) == $dirName {
        $'export use ./($in.name | path basename) *'
      } else {
        $'export use ./($in.name | path basename)'
      }
    }
    | str join (char newline)
    | { dir: $dir, content: $in }
  }
  | if not $dry_run {
    tee {
      par-each {
        let $f | $f.content | save -f ($f.dir | path join mod.nu)
      }
    }
  } else {
    log debug -f { 'DRY RUN' }
  }
}

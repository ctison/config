use ./utils/log.nu

export def main []: any -> any {
  let m = metadata
  let t = $in
  if (
    not ($t | describe | str starts-with 'table<')
    or $m.source? == 'ls'
  ) {
    return ($t | table -e)
  }
  let maxI = $t | length | $in - 1
  if $maxI < 1 {
    return ($t | first | table -e)
  }
  mut fullscreen = false
  mut i = 0
  clear -k
  ansi -e s | print -rn
  ansi cursor_off | print -rn
  loop {
    ansi -e u | print -rn
    ansi clear_screen_from_cursor_to_end | print -rn
    if $fullscreen {
      return ($t | table -e)
    }
    print $'(ansi yellow_bold)Page ($i)/($maxI)(ansi reset)'
    $t | get $i | table -e | print
    match (input listen -t [key resize]) {
      {type: key, code: left} => {
        $i = [0 ($i - 1)] | math max
      }
      {type: key, code: right} => {
        $i = [$maxI ($i + 1)] | math min
      }
      {type: key, code: f} => {
        $fullscreen = true
      }
      {type: key, code: q} => {
        ansi cursor_on | print -rn
        break
      }
    }
  }
  null
}

export def alt [--off]: nothing -> nothing {
  ansi -e (if $off {'?1049l'} else '?1049h') | print -rn
}

export def 'cursor up' [n = 1]: nothing -> nothing {
  ansi -e $'($n)A' | print -rn
}

export def 'cursor right' [n = 1]: nothing -> nothing {
  ansi -e $'($n)C' | print -rn
}

export def 'cursor down' [n = 1]: nothing -> nothing {
  ansi -e $'($n)B' | print -rn
}

export def 'cursor left' [n = 1]: nothing -> nothing {
  ansi -e $'($n)D' | print -rn
}

export def cursor [--off]: nothing -> nothing {
  ansi -e (if $off {'?25l'} else '?25h') | print -rn
}

export def 'cursor pos' []: nothing -> record<x:int,y:int> {
  term query (ansi cursor_position) --prefix (ansi csi) --terminator 'R'
  | decode
  | parse '{y};{x}'
  | into record
}

export def 'cursor to' [-x: int = 1, -y: int = 1]: nothing -> nothing {
  ansi -e $'($y);($x)H' | print -rn
}

export def 'scroll up' [lines = 1]: nothing -> nothing {
  ansi -e $'($lines)S' | print -rn
}

export def 'scroll down' [lines = 1]: nothing -> nothing {
  ansi -e $'($lines)T' | print -rn
}

export def ooo []: any -> any {
  ansi -e ?1049h | print -rn
  for i in 1..20 {
    [(random chars -l 1000) '' ''] | print
  }
  loop {
    match (input listen -t [key]) {
      {type: key, code: up, modifiers: ['keymodifiers(shift)']} => {
        scroll up 2
      }
      {type: key, code: down, modifiers: ['keymodifiers(shift)']} => {
        scroll down 2
      }
      {type: key, code: up} => { cursor up 5 }
      {type: key, code: right} => { cursor right 5 }
      {type: key, code: down} => { cursor down 5 }
      {type: key, code: left} => { cursor left 5 }
      {type: key, code: ' '} => {
        (cursor to
          -x (random int 1..(term size).columns)
          -y (random int 1..(term size).rows)
        )
      }
      {type: key, code: q} => {
        ansi -e ?1049l | print -rn
        break
      }
    }
  }
  null
}

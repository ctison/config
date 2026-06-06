$env.config.keybindings ++= [{
  name: cut_word_left
  modifier: control
  keycode: char_w
  mode: emacs
  event: { edit: CutWordLeft }
}, {
  name: cut_line_start
  modifier: control
  keycode: char_u
  mode: emacs
  event: { edit: CutFromLineStart }
}, {
  name: copy_commandline
  modifier: alt
  keycode: char_c
  mode: emacs
  event: {
    send: ExecuteHostCommand
    cmd: 'commandline | osc copy'
  }
}, {
  name: reload
  modifier: alt
  keycode: char_r
  mode: emacs
  event: {
    send: ExecuteHostCommand
    cmd: 'rl'
  }
}, {
  name: toggle_debug_mode
  modifier: alt
  keycode: char_d
  mode: emacs
  event: {
    send: ExecuteHostCommand
    cmd: 'log toggle-debug'
  }
}, {
  name: help
  keycode: char_e
  modifier: alt
  mode: emacs
  event: {
    send: ExecuteHostCommand
    cmd: '__kb_help'
  }
}, {
  name: job_unfreeze
  keycode: char_z
  modifier: control
  mode: emacs
  event: {
    send: ExecuteHostCommand
    cmd: 'job unfreeze'
  }
}, {
  name: tab_name
  modifier: alt
  keycode: char_n
  mode: emacs
  event: {
    send: ExecuteHostCommand
    cmd: 'z ac rename-tab ([~ (pwd | path relative-to ~)] | path join)'
  }
}]

const HELP_HISTORY_FILE = $nu.data-dir | path join history.help.txt

def _help []: nothing -> nothing {
  print ''
  loop {
    try {
      input --history-file $HELP_HISTORY_FILE 'Search: '
      | if ($in | is-empty) { break } else $in
      | h ...($in | split words)
    }
  }
}

def __kb_help []: nothing -> nothing {
  commandline
  | if $in == '' { return (_help) } else $in
  | ast -j $in
  | $in.block
  | from json
  | let json
  | $in.span.start + (commandline get-cursor)
  | let cursor

  $json.pipelines.elements.0.expr
  | enumerate
  | let json
  | length
  | let length

  $json
  | where {
    let i = $in.index
    let e = $in.item
    if ($e.pipe? | is-not-empty) {
      $e.pipe?.start <= $cursor and $cursor <= $e.pipe.end
    } else {
      ($e.span.start <= $cursor and ($cursor <= $e.span.end or $i + 1 >= $length)
      or $i == 0 and $cursor < $e.span.start)
    }
  }
  # | tee { to json | bat -l json }
  | match $in.0.item.expr {
    {Call: $internal} => {
      [
        $internal.head.span_source
        ...(
          if (which $internal.head.span_source).type == alias {
            $internal
            | get --optional arguments.Positional.span.span_source
            | compact
          } else []
        )
      ]
    }
    {ExternalCall: $external} => {
      [
        $external.0.expr.GlobPattern.0
        ...(
          $external
          | slice 1..
          | each -f { each { $in.Regular?.span.span_source } }
        )
      ]
    }
  }
  | if ($in | is-not-empty) { h ...$in }
  return
}

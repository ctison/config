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
    cmd: 'commandline | pbcopy'
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
}]

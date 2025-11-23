export def display-notification [title: string, message: string]: nothing -> nothing {
  match (uname | $in.operating-system) {
    'Darwin' => {
      osascript -e $'display notification "($message)" with title "($title)"'
    }
    'Linux' => {
      notify-send $title $message
    }
    $os => {
      error make {
        msg: $'Os not supported: $(os)'
      }
    }
  }
}

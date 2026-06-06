export const PORT = 8080

export def install [] {
  %ls /vscode-exts
  | where type == file and name =~ \.vsix$
  | input list -m
  | $in.name
  | each {
    log info { $'Installing ($in)' }
    ^code-server --install-extension $in | print
  }
  null
}

export def update [] {
  cd /vscode-exts
  open ($cfg.DIR_ | path join vscode extensions.txt)
  | lines
  | where $in not-starts-with '#'
  | each {
    api vscode ext download $in
  }
}

export def start [] {
  log info { $'Linking code-server configurations' }
  mkdir ~/.local/share/code-server/User/
  ln -sf ...($cfg.DIR_ | path join vscode * | glob $in) ~/.local/share/code-server/User/

  lc --absolute ~/.local/share/code-server/User/
  | print

  ln -sf ...(glob /config/_/vscode/favicon.*) (mise where code-server)/src/browser/media/

  log info { $'Installed code-server extensions:' }
  code-server --list-extensions
  with-env {
    PORT: $PORT
  } {
    log info { $'Starting code-server on port ($env.PORT)' }
    (code-server --auth none --disable-telemetry --disable-update-check
      --disable-workspace-trust -an (pwd | path basename) .
    )
  }
}

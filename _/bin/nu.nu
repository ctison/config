#!/usr/bin/env -S nu

# let home = $env.FILE_PWD | path join .. | path expand
let home = $env.FILE_PWD | path join nu | path expand

with-env {
  XDG_CONFIG_HOME: $home
  XDG_DATA_HOME: $home
  XDG_DATA_DIRS: null
} {
  exec nu
}

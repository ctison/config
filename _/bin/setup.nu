#!/usr/bin/env -S nu

source ../nushell/base/_.nu

const DIR_ = path self | path dirname | path expand | path join .. | path expand

def link [src: string, dest: path] {
  mkdir ($dest | path dirname)
  glob --no-symlink ($DIR_)/($src)
  | ln -fsvw ...$in ($dest | path expand)
}

let targets = {
  agents: {||
    link .agents ~/
  }
  alacritty: {||
    link alacritty ~/.config/
  }
  bash: {||
    link bash/* ~/
  }
  bun: {||

  }
  cagent: {||

  }
  cargo: {||

  }
  claude: {||

  }
  codex: {||

  }
  copilot: {||

  }
  fish: {||

  }
  fnox: {||

  }
  git: {||

  }
  hunk: {||

  }
  mise: {||

  }
  nushell: {||

  }
  nvim: {||

  }
  starship: {||

  }
  swift: {||

  }
  uv: {||

  }
  vim: {||

  }
  vscode: {||

  }
  zed: {||

  }
  zellij: {||

  }
  zsh: {||

  }
}

def main [
  --all(-a)
  ...choices: string
] {
  $choices
  | default --empty {
    $targets
    | columns
    | if not $all and (is-terminal -i) {
        input list --multi
      } else $in
  }
  | let choices

  for choice in $choices {
    print $'>>> Setting up ($choice)'
    try {
      do ($targets | get $choice)
    } catch {|err|
      print --stderr $'Error: ($err.msg)'
    }
  }

  sleep 1sec
}

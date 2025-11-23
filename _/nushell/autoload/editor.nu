# Setup $env conversions
$env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge (
  [EDITOR, VISUAL] | reduce -f {} {|it, acc|
    $acc | insert $it {
      from_string: {split row ' '}
      to_string: {str join ' '}
    }
  }
)

# Setup $env.{VISUAL,EDITOR}
do --env {
  let $editors = [hx, nvim, vim]
    | do-if ($env.TERM_PROGRAM? == 'vscode') {
      prepend ['code-insiders -w' 'code -w']
    }
  for $editor in $editors {
    let editor = $editor | split row ' '
    if (which $editor.0 | is-not-empty) {
      $env.VISUAL = $editor
      $env.EDITOR = $editor
      break
    }
  }
}

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
  let visuals = ['zed -w']
    | do-if ($env.TERM_PROGRAM? == 'vscode') {
      append ['code -w', 'code-insiders -w']
    }
  mut hasSetVisual = false
  for $visual in $visuals {
    let visual = $visual | split row ' '
    if (which $visual.0 | is-not-empty) {
      $env.VISUAL = $visual
      $hasSetVisual = true
      break
    }
  }
  for $editor in $editors {
    let editor = $editor | split row ' '
    if (which $editor.0 | is-not-empty) {
      $env.EDITOR = $editor
      if not $hasSetVisual {
        $env.VISUAL = $editor
      }
      break
    }
  }
}

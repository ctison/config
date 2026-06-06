@complete external
export def --wrapped main [...rest] {
  with-env {
    BAT_CONFIG_PATH: ($cfg.DIR_)/bat/bat.conf
  } {
    (bat
      --style=full,-numbers,-changes,-grid
      --tabs=2
      --pager less
      --set-terminal-title
      --theme 'Catppuccin Frappe' # cSpell:ignore Catppuccin
      ...$rest
    )
  }
}

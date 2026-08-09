# https://zellij.dev/documentation/cli-actions.html

export def 'ac go-to-parent-tab' [index: number] {
  if $env.ZELLIJ_PARENT_SESSION_NAME? != null {
    load-env {
      ZELLIJ_SESSION_NAME: $env.ZELLIJ_PARENT_SESSION_NAME
    }
  }
  zellij ac go-to-tab $index
}

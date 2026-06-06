@complete external
export def --wrapped main [...rest] {
  with-env {
    CODANNA_EMBED_URL: 'http://127.0.0.1:'
    CODANNA_EMBED_MODEL: ''
    CODANNA_EMBED_DIM: 768
    CODANNA_EMBED_API_KEY: 'sk-secret'
  } {
    ^codanna ...$rest
  }
}

const DEFAULT_BASE_URL = '127.0.0.1:7777'

export def 'chat completions' [
  --base-url: string = $DEFAULT_BASE_URL
  model: string = 'default'
]: string -> string {
  (http post -t application/json
    ($base_url)/v1/chat/completions
    {
      model: $model
      messages: [{ role: user, content: $in }]
      response_format: { type: json_object }
    }
  )
}

export def completions [
  --base-url: string = $DEFAULT_BASE_URL
  model: string = 'default'
]: string -> string {
  (http post -t application/json
    ($base_url)/v1/completions
    {
      model: $model
      messages: [{ role: user, content: $in }]
      response_format: { type: json_object }
    }
  )
}

export def models [
  --base-url: string = $DEFAULT_BASE_URL
]: nothing -> table {
  http * ($base_url)/v1/models
}

export def embeddings [
  --base-url: string = $DEFAULT_BASE_URL
]: nothing -> table {
  http * ($base_url)/v1/embeddings
}

export def health [
  --base-url: string = $DEFAULT_BASE_URL
]: nothing -> table {
  http * ($base_url)/health
}

export def metrics [
  --base-url: string = $DEFAULT_BASE_URL
]: nothing -> table {
  http * ($base_url)/health
}

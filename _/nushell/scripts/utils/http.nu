use ./fmt.nu

export def * [
  --method: string = 'GET'
  --headers(-H): record
  --raw(-r)
  --insecure(-k)
  --full(-f)
  --allow-errors(-e)
  --redirect-mode(-R): string = 'f'
  url: string
  data: oneof<binary, string> = ''
] {
  let method_span = (metadata $method).span
  let headers = $headers | get-headers
  match ($method | str downcase) {
    'get' => {(
      http get
        --headers $headers
        --raw=($raw)
        --insecure=($insecure)
        --full=($full)
        --allow-errors=($allow_errors)
        --redirect-mode $redirect_mode
        $url
    )}
    'post' => {(
      http post
        --headers $headers
        --raw=($raw)
        --insecure=($insecure)
        --full=($full)
        --allow-errors=($allow_errors)
        --redirect-mode $redirect_mode
        $url
        $data
    )}
    'head' => {(
      http head
        --headers $headers
        --insecure=($insecure)
        $url
    )}
    'options' => {(
      http options
        --headers $headers
        --allow-errors=($allow_errors)
        --insecure=($insecure)
        $url
    )}
    'patch' => {(
      http patch
        --headers $headers
        --raw=($raw)
        --insecure=($insecure)
        --full=($full)
        --allow-errors=($allow_errors)
        --redirect-mode $redirect_mode
        $url
        $data
    )}
    'put' => {(
      http put
        --headers $headers
        --raw=($raw)
        --insecure=($insecure)
        --full=($full)
        --allow-errors=($allow_errors)
        --redirect-mode $redirect_mode
        $url
        $data
    )}
    _ => {(
      fmt error {
        msg: $'Wrong HTTP method'
        label: $'Method is ($method)'
        span: $method_span
      }
    )}
  }
}

def get-headers []: oneof<nothing, record> -> record {
  default {} | upsert user-agent (random chars -l (random int 2..5))
}

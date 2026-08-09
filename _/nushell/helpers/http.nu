export const METHODS = [get post head options patch put]

def complete-method [] { $METHODS }

export def * [
  --method(-M): string@complete-method = 'GET'
  --headers(-H): record
  --raw(-R)
  --content-type(-t): string
  --insecure(-k)
  --full(-f)
  --allow-errors(-e)
  --redirect-mode(-r): string = 'f'
  url: string
  data: any = ''
] {
  let method_span = ($method | metadata).span
  let headers = $headers | get-headers
  match ($method | str lowercase) {
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
        --content-type $content_type
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

export def sse [] {
  lines
  | generate {|line, acc = { data: [] }|
    match ($line | split row -n 2 ':' | each { str trim }) {
      [$prefix $content] if $prefix == 'id' => {
        { next: ($acc | upsert id $content) }
      }
      [$prefix $content] if $prefix == 'event' => {
        { next: ($acc | upsert event $content) }
      }
      [$prefix $content] if $prefix == 'data' => {
        log info $content
        { next: ($acc | update data { append $content }) }
      }
      [$empty] if $empty == '' => {
        if ($acc == {data: []}) {
          { next: $acc }
        }
        { next: { data: [] }, out: ($acc | update data { str join (char newline) }) }
      }
      _ => { log warning $'Unexpected: ($line)' }
    }
  }
}

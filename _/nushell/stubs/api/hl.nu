# https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api

const API_URL = 'https://api.hyperliquid.xyz'

# === HELPERS ===

def '_http get' [path: string, params?: record, ...rest] {
  (http get --redirect-mode manual --full=(log is-debug)
    $'($API_URL)($path)($params | url into query)'
  )
  | if (log is-debug) {
    log debug $in
    $in.body
  } else $in
}

def '_http post' [path: string, params?: record, payload?: any] {
  (http post --redirect-mode manual --full=(log is-debug)
    --content-type application/json
    $'($API_URL)($path)($params | url into query)'
    ($payload | compact | to json -r)
  )
  | if (log is-debug) {
    log debug $in
    $in.body
  } else $in
}

# === INFO ENDPOINTS ===

# Get a user's fills
export def 'user fills' [address: string] {
  _http post /info {} {
    type: 'userFills'
    user: $address
    aggregateByTime: true
  }
}

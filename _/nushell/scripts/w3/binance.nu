use ../utils/http.nu

# https://developers.binance.com/docs/binance-spot-api-docs/rest-api/general-api-information
# https://developers.binance.com/docs/wallet/general-info
# https://developers.binance.com/docs/fiat/general-info

# cSpell:ignore sapi

export const URLS = [
  https://api.binance.com
  https://api-gcp.binance.com
  https://api1.binance.com
  https://api2.binance.com
  https://api3.binance.com
  https://api4.binance.com
]

export def api [
  --endpoint: string
  --method = GET
  --api-key
  path: string
  body?: oneof<string, binary>
] {
  let url = $'($endpoint | default {$URLS | get (random int 0..<($URLS | length))})($path)'
  let headers = {} | if ($api_key) {
      $in | insert X-MBX-APIKEY $env.BINANCE_API_KEY
    } else $in

  let start_time = date now
  let response = try {
    http * --method $method -fH $headers $url $body
  } catch {|err| $err | table -e | print; return}

  let end_time = date now
  let cdn_time = $response.headers.response | where name == date | $in.0.value | into datetime
  log debug $'($method) ($path)' (
    $response
    | insert timing {
      start_time: ($start_time | format date)
      cdn_date: ($cdn_time | format date)
      end_time: ($end_time | format date)
      request_duration: ($end_time - $start_time)
      response_duration: ($end_time - $cdn_time)
    } | table -e
  )
  $response.body
}

def compute-signature [
  --secret-key: string
]: [
  record -> record
] {
  $in
  | upsert recvWindow {default 5000}
  | upsert timestamp {default {date now | format date '%s%f' | str replace -r '.{6}$' ''}}
  | insert payload ($in | items {|k v| $'($k)=($v)'} | str join '&')
  | insert signature (
    # cSpell:ignore dgst hmac
    $in.payload | openssl dgst -sha256 -hmac ($secret_key | default {$env.BINANCE_SECRET_KEY})
  )
  | insert query $'($in.payload)&signature=($in.signature)'
}

export def ping [] {
  api /api/v3/ping
}

export def server-time [] {
  api /api/v3/time
  | do {|now| {
    now: $now
    serverTime: ($'($in.serverTime)000000' | into datetime)
  }} (date now)
  | upsert diff {|it| $it.serverTime - $it.now}
  | update now {format date}
  | table -e
}

# https://developers.binance.com/docs/wallet/asset/query-user-wallet-balance
export def wallet [params: record = {}]: nothing -> table {
  api --api-key $'/sapi/v1/asset/wallet/balance?($params
  | compute-signature
  | $in.query
  )'
}

# https://developers.binance.com/docs/wallet/asset/user-assets
export def assets [params: record = {}]: nothing -> table {
  api --api-key --method POST $'/sapi/v3/asset/getUserAsset?($params
  | upsert needBtcValuation {default true}
  | compute-signature
  | $in.query
  )'
}

# https://developers.binance.com/docs/fiat/rest-api
export def 'fiat history' [params: record = {}]: nothing -> table {
  api --api-key $'/sapi/v1/fiat/orders?($params
  | upsert transactionType {default 'withdraw'}
  | compute-signature
  | $in.query
  )'
}

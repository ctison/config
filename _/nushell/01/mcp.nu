const STATE_KEY = $.mcp

def complete-mcp-version [] {
  [ '2025-11-25' '2025-06-18' '2025-03-26' '2024-11-05' ]
}

export def --env initialize [
  url: string
  version: string@complete-mcp-version
] {
  state set $STATE_KEY { { url: $url, version: $version } }
  (http post $url -f
    -H { Accept: 'application/json, text/event-stream' }
    -t application/json (json-rpc --id (random chars) initialize {
      "protocolVersion": "2025-11-25",
      "capabilities": {},
      clientInfo: {
        name: mcp-list
        version: 0.0.0
      }
    } | tee {
      log debug $in
    })
  )
  | tee {
    $in.headers?.response?.mcp-session-id?
    | state set [$STATE_KEY $.session-id] { $in }
  }
}

export def sse [
  --url: string
  --version: string@complete-mcp-version
  --session-id: string
] {
  let state = state get $STATE_KEY
  let url = $url | default { $state.url }
  let version = $version | default { $state.version }
  let sessionId = $session_id | default { $state.sessionId? }
  (http get $url -f
    -H {
      Accept: 'application/json, text/event-stream'
      MCP-Protocol-Version: $version
      Mcp-Session-Id: $sessionId
    }
  )
}

export def initialized [
  url: string
  version: string@complete-mcp-version
] {
  (http post $url -f
    -H {
      Accept: 'application/json, text/event-stream'
      MCP-Protocol-Version: $version
    }
    -t application/json (json-rpc notifications/initialized | compact | tee {
      log debug $in
    })
  )
  | from json
}

export def tools-list [url: string] {
  (http post $url
    -H { Accept: 'application/json, text/event-stream' }
    -t application/json (json-rpc tools/list {})
  )
  | from json
}

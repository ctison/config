export def main [
  method: string
  params?: record
  --id: oneof<string, number>
]: [
  nothing -> record<
    jsonrpc: string
    id: oneof<nothing, string, number>
    method: string
    params: oneof<nothing, record>
  >
] {
  {
    jsonrpc: '2.0'
    id: $id
    method: $method
    params: $params
  }
}

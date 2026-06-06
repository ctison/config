const DEFAULT_BASE_URL = '127.0.0.1:7777'

export def messages [
  baseUrl: string = $DEFAULT_BASE_URL
]: string -> string {
  http * ($baseUrl)/v1/messages
}

export def count-tokens [
  baseUrl: string = $DEFAULT_BASE_URL
]: string -> table {
  http * ($baseUrl)/v1/messages/count_tokens
}

export def status [
  baseUrl: string = $DEFAULT_BASE_URL
]: nothing -> table {
  http * ($baseUrl)/v1/status
}

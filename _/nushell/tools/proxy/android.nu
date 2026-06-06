export def start [
  --proxy-port = 7777
] {
  adb reverse tcp:($proxy_port) tcp:($proxy_port)
  adb shell settings put global http_proxy 127.0.0.1:($proxy_port)
}

export def status [] {
  adb reverse --list
  | log info { $'Reverse socket:(char newline)($in)' }
  adb shell settings list global '|' grep -i proxy
  | log info -R
  null
}

export def stop [
  --proxy-port = 7777
] {
  log info 'Deleting http_proxy from phone'
  try { adb shell settings delete global http_proxy }
  try { adb shell settings delete global global_http_proxy_host }
  try { adb shell settings delete global global_http_proxy_port }
  log info $'Removing reverse socket tcp:($proxy_port)'
  try { adb reverse --remove tcp:($proxy_port) }
}

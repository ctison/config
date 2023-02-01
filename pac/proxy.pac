function FindProxyForURL(url, host) {
  if (host === 'ctison.io' || shExpMatch(host, '*.ctison.io')) {
    return 'PROXY 127.0.0.1:8888; DIRECT'
  }
  return 'DIRECT'
}

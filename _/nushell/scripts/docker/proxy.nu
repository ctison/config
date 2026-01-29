const DIR = path self | path dirname

export def start [-i]: nothing -> nothing {
  build
  (docker network create proxy
    -d bridge
    -o com.docker.network.bridge.enable_ip_masquerade=false
    --internal
  )
}

export def build []: nothing -> nothing {
  (^docker build --pull --load -t ctison/proxy --platform linux/amd64 ($DIR | path join proxy/))
}

export def run []: nothing -> nothing {
  build
  docker run -it --rm --platform linux/amd64 --name proxy --hostname proxy --cap-add NET_ADMIN ctison/proxy
}

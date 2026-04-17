use ../utils/cfg.nu DIR_CONTANERS_STATE

const DIR_VOLUME = $DIR_CONTANERS_STATE | path join mitmproxy
const IMAGE = 'mitmproxy/mitmproxy'

export def pull [] {
  ^docker pull $IMAGE
}

export def start [] {
  mkdir $DIR_VOLUME
  (^docker run --name mitm -d --rm
    -p 127.0.0.1:9999:8080
    -p 127.0.0.1:9998:8081
    -v $'($DIR_VOLUME):/home/mitmproxy/.mitmproxy'
    # cSpell:words mitmweb
    $IMAGE mitmweb --showhost --web-host 0.0.0.0
  )
}

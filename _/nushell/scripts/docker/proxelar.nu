use ../utils/cfg.nu DIR_CONTANERS_STATE


const DIR_VOLUME = $DIR_CONTANERS_STATE | path join proxelar
const IMAGE = 'ghcr.io/emanuele-em/proxelar' # cSpell:ignore emanuele

export def pull [] {
  ^docker pull $IMAGE
}

export def start [] {
  mkdir $DIR_VOLUME
  (^docker run --name proxelar -d --rm
    -p 127.0.0.1:9999:8080
    -p 127.0.0.1:9998:8081
    $IMAGE --interface gui --addr 0.0.0.0
  )
}

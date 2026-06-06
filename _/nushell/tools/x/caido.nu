export const NAME = 'caido'
export const IMAGE = 'caido/caido'
export const VERSION = 'latest'
const SELECT = [x-port]

export use ./_docker.nu *

@complete external
export def --wrapped main [...rest] {
  docker run -it --rm $IMAGE caido-cli ...$rest
}

export def start []: nothing -> any {
  let c = ls -cR
  (docker run --rm -it
    --network dev
    --name caido
    -l x-app=($NAME)
    -p 127.0.0.1:9999:9999
    -p 127.0.0.1:9988:80
    $IMAGE
    caido-cli
      --proxy-listen 0.0.0.0:9999
      --ui-listen 0.0.0.0:80
      --ui-domain localhost
      --debug
      --no-sync
      # --no-renderer-sandbox
      # --import-ca-cert caido.crt
      # --import-ca-cert-pass ???
      --allow-guests
      # --safe
  )
}

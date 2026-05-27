const IMAGE = 'mitmproxy/mitmproxy'
const DIR = $cfg.DIR_STATE_GLOBAL | path join mitmproxy

alias nu-cd = cd

export def --env cd [] {
  mkdir $DIR
  nu-cd $DIR
}

export def options [] {
  docker run -it --rm $IMAGE mitmproxy --options
  | collect
  | bat -l yaml
}

export def --wrapped main [...rest] {
  (docker run --name mitmproxy -it --rm -p 127.0.0.1:7777:7777 $IMAGE
    mitmproxy -m regular@0.0.0.0:7777 --show-ignored-hosts
    --set console_layout=vertical
    --set console_quickhelp_visible=false
    ...$rest
  )
}

export def status [] {
  docker ps | where name == mitmproxy
}

export def stop [] {
  docker stop mitmproxy
}

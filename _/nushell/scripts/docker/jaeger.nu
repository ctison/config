use ../utils/log.nu
use ./docker.nu
use ../utils/cfg.nu DIR_CONFIG

const LABEL_APP = $.'dev.app'
const LABEL_CWD = $.'dev.cwd'

export def pull []: nothing -> nothing {
  ^docker pull jaegertracing/jaeger
}

export def start []: nothing -> any {
  (^docker run --rm -d
    -p 16686:16686
    -p 16687:16687
    -p 4317:4317
    -p 4318:4318
    jaegertracing/jaeger
  )
}

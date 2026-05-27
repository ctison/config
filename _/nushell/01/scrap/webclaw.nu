const IMAGE = 'ghcr.io/0xmassi/webclaw'
const DIR = $cfg.DIR_STATE_GLOBAL | path join webclaw

@complete external
export def --wrapped _ [...rest] {
  if (has-tool webclaw) {
    ^webclaw ...$rest
  } else {
    # cSpell:ignore 0xmassi
    docker run --rm $IMAGE ...$rest
  }
}

@complete external
export def --wrapped map [...rest] {
  _ --map ...$rest
  | lines
}

@complete external
export def crawl [url: string] {
  $DIR | path join ($url | url parse).host
  | let dir | mkdir $dir
  | log info { $'Run dir: ($dir)' }

  (docker run --rm -v ($dir):/data $IMAGE
    --crawl --output-dir /data
    --sitemap
    $url
    # --only-main-content
    --depth 1
    --max-pages 1000
    # --llm-provider
    # --llm-base-url
    # --llm-model
    # --api-key
  )

}

const DIR = $cfg.DIR_STATE_GLOBAL | path join kreuzcrawl
const DIR_CRAWLS = $DIR | path join crawls
const DIR_BOOKS = $DIR | path join books

@complete external
export def --wrapped main [...$rest] {
  if (has-tool kreuzcrawl) {
    ^kreuzcrawl ...$rest
  } else {
    docker run --rm ghcr.io/kreuzberg-dev/kreuzcrawl:latest ...$rest
  }
}

export def langs [] {
  $in.pages
  | each -k { $in.metadata.html_lang }
  | into bucket
}

export def urls [] {
  $in.pages
  | each {
    $in.normalized_url
    | (url parse).path
    | path split
  }
  | into trie
}

export def crawl [url: string] {
  mkdir $DIR_CRAWLS
  $DIR_CRAWLS
  | path join (
    $url | (url parse).host | $'($in).msgpackz'
  )
  | let dest

  main crawl --respect-robots-txt --stay-on-domain $url
  | from json
  | to msgpackz
  | save -f $dest

  ls $dest
}

export def load [] {
  ls $DIR_CRAWLS
  | input list
  | open $in.name
  | from msgpackz
  | log debug -R { langs }
  | log debug -R { urls }
}

export def book [] {
  default { load }
  | let crawl
  | $in.final_url
  | (url parse).host
  | let dir

  $DIR_BOOKS
  | path join $dir
  | let dir
  | mkdir $dir

  $crawl.pages
  | where metadata.html_lang == 'en-US'
  | par-each {
    let page

    $page.normalized_url
    | (url parse).path
    | path split
    | let frags

    $dir
    | path join ...($frags | slice 1..-2)
    | let dir
    | mkdir $in

    $frags
    | last
    | path parse
    | $'($in.stem | default -e index).md'
    | let f

    $page.markdown.content
    | save -f ($dir | path join $f)
  }
  | ignore
}

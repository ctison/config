@complete external
export def --wrapped main [...rest] {
  swift ($cfg.DIR_ | path join swift default-handlers-files.swift) ...$rest
}

def --wrapped 'main json' [...rest] {
  let result = main ...$rest | complete
  if $result.exit_code != 0 {
    error make { msg: ($result.stderr | str trim) }
  }

  $result.stdout
  | from json
}

export def --wrapped ls [
  --raw(-R)
  ...rest
] {
  main json ls ...$rest
  | sort-by appId
  | if $raw { $in } else {
    select appId contentTag contentType
  }
}

export def --wrapped set [
  contentType: string
  appId: string
  --role: string
  ...rest
] {
  let args = if ($role | is-empty) {
    [set $contentType $appId]
  } else {
    [set --role $role $contentType $appId]
  }

  main json ...$args ...$rest
}

export def --wrapped rm [
  target: string
  --content-type
  --content-tag
  ...rest
] {
  if $content_type and $content_tag {
    error make { msg: 'Use only one of --content-type or --content-tag' }
  }

  let args = if $content_type {
    [rm --content-type $target]
  } else if $content_tag {
    [rm --content-tag $target]
  } else {
    [rm $target]
  }

  main json ...$args ...$rest
}

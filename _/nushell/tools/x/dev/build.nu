export def main [
  --platform(-a): string # default: $'linux/(uname | $in.machine)'
  --pull(-p)             # pull base image
  --no-cache             # no cache
  --debug(-d)
]: nothing -> nothing {
  log info $'IMAGE: ($IMAGE)'
  let platform = $platform | default { $'linux/(uname | $in.machine)' }
  cd $cfg.DIR_ROOT
  [
    '*'
    !/setup.sh
    ...(git ls-files --cached --others --exclude-standard _
      | lines
      | each { $'!/($in)' } )
  ]
  | str join (char newline)
  | save -f .dockerignore
  bat .dockerignore
  input 'Continue: ' | if $in != 'y' { return }
  (^fnox run -P github
      docker build --platform $platform
        ...(if $pull {[--pull]} else [])
        ...(if $debug {[--debug]} else [])
        ...(if $no_cache {[--no-cache]} else [])
        --secret type=env,id=GITHUB_TOKEN
        --load -t ($IMAGE):($VERSION) $cfg.DIR_ROOT
  )
}

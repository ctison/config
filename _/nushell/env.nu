$env.SHELL  = 'nu'
$env.LC_ALL = 'C'

@complete external
def --wrapped nu [...rest] { ^$nu.current-exe ...$rest }

source ./scripts/utils/__source.nu

const self = path self | path expand
log scope --enter $self

$env.PATH = [
  $cfg.DIR_BIN
] ++ $env.PATH

env-path add ...[
  $cfg.DIR_BIN
  /sbin /usr/sbin /bin /usr/bin
  ~/.cargo/bin ~/go/bin
  ~/.local/bin ~/.docker/bin
  /opt/homebrew/bin
]

if ($env.TERM_PROGRAM? == 'vscode') {
  env-path add ...[
    '/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/'
    '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/'
  ]
}

if (which -a mise | where type == external | is-not-empty) {
  mise activate
}

mkdir $nu.cache-dir
const starship = $nu.cache-dir | path join 'starship.nu'
const carapace = $nu.cache-dir | path join 'carapace.nu'

touch $starship $carapace

if-tool-run starship {
  starship init nu | save -f $starship
  log debug $'Saved starship to (fmt link $starship)'
}

if-tool-run carapace {
  load-env {
    CARAPACE_EXCLUDES: 'eza'
    CARAPACE_HIDDEN: 2
    CARAPACE_MERGEFLAGS: 1
    CARAPACE_NOSPACE: '*'
  }
  with-env {
    CARAPACE_ENV: 0
  } {
    (carapace _carapace nushell) | save -f $carapace
    log debug $'Saved carapace to (fmt link $carapace)'
  }
}

log scope --exit $self

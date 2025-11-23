umask 0077

use ./scripts/cfg
cfg log debug $'>>> Loading (cfg fmt -bu env.nu)'

$env.SHELL  = 'nu'
$env.LC_ALL = 'C'

@complete external
def --wrapped nu [...rest] { ^$nu.current-exe ...$rest }

def dbg [] { tee { describe -d | reject rust_type | table -c | print } }

def rl [
  --log(-l): string
  --clear-cache(-c)
  --login(-f)
] {
  if ($log != null) { cfg log set-log-level $log }
  if ($clear_cache) { cfg cache clear }
  if ($login) { exec login -lfq $env.USER }
  exec $nu.current-exe
}

def --env do-if [condition: oneof<bool, closure>, closure: closure] {
  match ($condition | describe) {
    'closure' => {if ($in | do $condition) {do --env $closure} else $in}
    'bool' => {if $condition {do --env $closure} else $in}
  }
}

cfg path add [
  /sbin /usr/sbin /bin /usr/bin
  $cfg.DIR_BIN
  ~/.cargo/bin ~/go/bin
  ~/.local/bin ~/.docker/bin
  /opt/homebrew/bin
]

if ($env.TERM_PROGRAM? == 'vscode') {
  cfg path add [
    '/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/'
  ]
}

mkdir $nu.cache-dir
const starship = $nu.cache-dir | path join 'starship.nu'
const carapace = $nu.cache-dir | path join 'carapace.nu'

touch $starship $carapace

cfg if-tool-run starship {
  starship init nu | save -f $starship
  cfg log debug $'Saved starship to (cfg fmt link $starship)'
}

cfg if-tool-run carapace {
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
    cfg log debug $'Saved carapace to (cfg fmt link $carapace)'
  }
}

cfg log debug $'<<< Exiting (cfg fmt -bu env.nu)'

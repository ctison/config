use ./fmt.nu
use ./log.nu
use ./state.nu

const STATE_VARS = [MISE_SHELL __MISE_DIFF __MISE_SESSION __MISE_SHIM]

@complete external
export def --env --wrapped main [command?: string, --help, ...rest] {
  const commands = [deactivate shell sh]
  match $command {
    'activate' => { state set $.mise.env.MISE_SHELL nu }
    $s if $s in $commands => { ^mise $command ...$rest | compute-updates | update-env }
    _ => { ^mise $command ...$rest }
  }
}

export def --env activate [] {
  state set $.mise.env.MISE_SHELL nu
  if (state set $.mise.activated true) == true {
    return
  }
  $env.config.hooks = (
    $env.config.hooks? | default {}
    | upsert pre_prompt {
      default [] | append [{mise-hook}]
    }
    | upsert env_change {
      default {} | upsert PWD {
        default [] | append [{mise-hook}]
      }
    }
  )
  mise-hook
}

def compute-updates []: string -> record<load: record, hide: list<string>> {
  $in | from csv -n --no-infer | rename op name value | reduce -f {load:{} hide:[]} {|row acc|
    match $row.op {
      'set' => {
        match $row.name {
          $name => { $acc | update load { merge {
            $name: (if ($name == 'PATH') {$row.value | split row (char env_sep)} else $row.value)
          }}}
        }
      }
      'hide' => {
        match $row.name {
          _ => { $acc | update hide { append $row.name } }
        }
      }
      _ => { log error $'(fmt -b mise) env operator not found: ($row)'; $acc }
    }
  }
}

def --env update-env []: record<load: record, hide: list<string>> -> nothing {
  tee { log trace 'Mise updates' ($in | table -e) }
  load-env $in.load
  hide-env ...$in.hide
}


def --env mise-hook [] {
  with-env (state get $.mise.env) {
    ^mise hook-env -s nu | compute-updates
  } | update-env
}

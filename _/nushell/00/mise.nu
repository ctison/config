use ./has-tool.nu

@complete external
export def --wrapped main [...rest] {
  if (has-tool fnox) {
    fnox -P github --if-missing ignore run mise ...$rest
  } else {
    mise ...$rest
  }
}

@complete external
export def --wrapped --env deactivate [...$rest] {
  main deactivate ...$rest
  | compute-updates
  | update-env
}

@complete external
export def --wrapped --env shell [...$rest] {
  with-env {
    MISE_VERBOSE: true
    MISE_ALWAYS_KEEP_DOWNLOAD: true
  } {
    main shell ...$rest
    | log debug -f
  }
  | compute-updates
  | update-env
}

export alias sh = shell

@complete external
export def --env activate [] {
  state set $.mise.env.MISE_SHELL { 'nu' }
  if (state get $.mise.activated?) == true {
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
  state set $.mise.activated { true }
  mise-hook
}

# Parse mise updates
def compute-updates []: string -> record<load: record, hide: list<string>> {
  from csv -n --no-infer
  | rename op name value
  | reduce -f { load: {} hide: [] } {|row acc|
    match $row.op {
      'set' => {
        match $row.name {
          $name => {
            $acc | update load {
              merge {
                $name: (if ($name == 'PATH') {$row.value | split row (char env_sep)} else $row.value)
              }
            }
          }
        }
      }
      'hide' => {
        match $row.name {
          _ => { $acc | update hide { append $row.name } }
        }
      }
      _ => {
        log error { $'(fmt -b mise) env operator not found: ($row)' }
        $acc
      }
    }
  }
}

def --env update-env []: record<load: record, hide: list<string>> -> nothing {
  tee {
    log trace 'Mise updates'
    log trace -R ($in | table -e)
  }
  load-env $in.load
  hide-env ...$in.hide
}


def --env mise-hook [] {
  with-env (state get $.mise.env) {
    main hook-env -s nu
    | compute-updates
  }
  | update-env
}

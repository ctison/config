use ../utils/log.nu
use ../utils/cfg.nu
export use ./notifs.nu
export use ./starring.nu

export const DIR_GIT = $cfg.DIR_X | path join x

export def open [repo: string]: [nothing -> nothing] {
  let dir = $DIR_GIT | path join ($repo | url parse | $in.path | str replace -r ^/+ '')
  if not ($dir | path exists) {
    git clone $repo $dir
  }
  ^open -a `/Applications/Visual Studio Code - Insiders.app` $dir
}

export def 'release latest' [repo: string]: nothing -> record {
  gh api /repos/($repo)/releases/latest
  | from json
}

export def 'clean gha' [repo?: string]: nothing -> list<string> {
  let repo = $repo | default {guess}
  gh api $'/repos/($repo)/actions/runs?status=failure'
    | from json | $in.workflow_runs.id
    | tee { log info $'Found (length) failed jobs. Deleting...' }
    | par-each {
      gh api -X DELETE $'/repos/($repo)/actions/runs/($in)'
    }
}

export def guess []: [
  nothing -> table<owner:string, repo: string, full: string>
] {
  git remote get-url origin
  | parse 'https://github.com/{owner}/{repo}'
  | insert full {$'($in.owner)/($in.repo)'}
}

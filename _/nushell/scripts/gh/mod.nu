use ../log

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

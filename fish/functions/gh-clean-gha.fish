function gh-clean-gha -a repo
  argparse -N 1 -X 1 -- $argv
  or return

  set -l failed (gh api "/repos/$repo/actions/runs?status=failure" \
    | jq -r '.workflow_runs[].id')

  echo "Failed jobs: $(count $failed)"

  for id in $failed
    gh api -X DELETE "/repos/$repo/actions/runs/$id"
  end
end
complete -c gh-clean-gha -f

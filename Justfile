set dotenv-load := false

just := "just -f '" + justfile() + "'" + ' -d "$PWD"'

# $NAME is used by templating targets
export NAME := `echo ${NAME:-${PWD##*/}}`

# Display available commands
@default:
  {{just}} --list --unsorted 

# Template a kustomize app
@k8z dir=`$PWD`:
  cd '{{justfile_directory()}}/gomplate/k8z' && gomplate --output-dir '{{invocation_directory()}}/{{dir}}'

# Start a k3d cluster
@k3d name:
  k3d cluster create --config '{{justfile_directory()}}/k3d/config.yaml' '{{name}}'
  mkdir -p ~/.kube/configs/k3d
  k3d kubeconfig get {{name}} | sed 's/0\.0\.0\.0/127.0.0.1/' > ~/.kube/configs/k3d/'{{name}}.yaml'

# Create an issue in linear
linear issueTitle:
  #!/usr/bin/env bash
  set -euo pipefail
  SECRETS=$(<'{{justfile_directory()}}/.secrets.json')
  export API_KEY=$(echo "$SECRETS" | jq -r .linear.apiKey)
  export TEAM_ID=$(echo "$SECRETS" | jq -r .linear.teamId)
  export ASSIGNEE_ID=$(echo "$SECRETS" | jq -r .linear.assigneeId)
  export TITLE='{{issueTitle}}'
  BRANCH_NAME=$(linear-create-issue | jq -r .data.issueCreate.issue.branchName)
  {{just}} git-create-branch "$BRANCH_NAME"

# Create a new git branch from origin/main
git-create-branch branchName:
  git fetch origin main
  git checkout -b '{{branchName}}' origin/main

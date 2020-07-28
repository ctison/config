#!/bin/bash
umask 0077
set -euxo pipefail
shopt -s nullglob

VERSION=$(curl -s https://api.github.com/repos/user/repo/releases/latest | jq -r .tag_name | sed s/^v//)
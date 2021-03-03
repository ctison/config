#!/bin/bash
umask 0077
shopt -s nullglob
set -euo pipefail

VERSION=$(curl -fsS https://api.github.com/repos/user/repo/releases/latest | jq -r .tag_name)
echo "VERSION=$VERSION"
if [ $# = 1 ] && [ "$1" = 'version' ]; then exit 0; fi
set -x
curl -fsSLO
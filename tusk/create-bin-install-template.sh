#!/bin/bash
umask 0077
shopt -s nullglob
set -euxo pipefail

VERSION=$(curl -s https://api.github.com/repos/user/repo/releases/latest | jq -r .tag_name | sed s/^v//)
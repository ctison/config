#!/bin/bash
set -euo pipefail
shopt -s nullglob

echo "${NAME:-${PWD##*/}}"

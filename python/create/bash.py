#!/usr/bin/env python3

from subprocess import run
from sys import argv, stderr
from textwrap import dedent


def bootstrap_bash(*paths: str) -> None:
  """Bootstrap bash scripts at paths."""
  for arg in paths:
    try:
      with open(arg, mode='x') as f:
        print(dedent('''\
          #!/bin/bash
          umask 0077
          shopt -s nullglob
          set -euxo pipefail

          # Current script's directory
          DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
        '''), end='', file=f)
      # Try to open file with VSCode
      try:
        run(['code', arg])
      except:
        pass
    except Exception as err:
      raise Exception(f"Failed to bootstrap '{arg}': {err}") from err


if __name__ == '__main__':
  if len(argv) == 1:
    print(dedent(f'''\
      Usage: {argv[0]} PATH [...]
      '''), end='')
    exit(0)

  try:
    bootstrap_bash(*argv[1:])
  except Exception as err:
    print(err, file=stderr)
    exit(1)

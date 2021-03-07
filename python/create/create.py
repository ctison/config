#!/usr/bin/env python3

from os.path import dirname, realpath
from sys import argv, stderr
from textwrap import dedent
from .python import bootstrap_py

# Compute and store current script directory
CSD = realpath(dirname(__file__))

if __name__ == '__main__':
  if len(argv) == 1:
    print(dedent(f'''\
      Usage: {argv[0]} NAME [...]

      Boostrap python script(s) named NAME at {CSD}.
    '''), end='')
    exit(0)

  try:
    bootstrap_py(*[f'{CSD}/{name}' for name in argv[1:]])
  except Exception as exc:
    print(exc, file=stderr)

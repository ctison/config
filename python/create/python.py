#!/usr/bin/env python3

from os import chmod
from subprocess import run
from sys import argv, stderr
from textwrap import dedent


def bootstrap_py(*paths: str) -> None:
  '''Bootstrap python scripts at paths.'''
  for arg in paths:
    try:
      with open(arg, mode='w') as f:
        chmod(f.fileno(), 0o700)
        print(dedent('''\
          #!/usr/bin/env python3

          from os.path import dirname, realpath
          from sys import argv
          from textwrap import dedent

          # Compute and store current script directory
          CSD = realpath(dirname(__file__))

          if __name__ == '__main__':
            if len(argv) == 1:
              print(dedent(f\'''\\
                Usage: {argv[0]} ...
              \'''), end='')
              exit(0)

        '''), end='', file=f)
      # Try to open file with VSCode
      try:
        run(['code', arg])
      except:
        pass
    except Exception as exc:
      raise Exception(f"Failed to bootstrap '{arg}': {exc}") from exc


if __name__ == '__main__':
  if len(argv) == 1:
    print(dedent(f'''\
      Usage: {argv[0]} PATH [...]

      Boostrap python script(s) at every PATH.
    '''), end='')
    exit(0)

  try:
    bootstrap_py(*argv[1:])
  except Exception as exc:
    print(exc, file=stderr)
    exit(1)

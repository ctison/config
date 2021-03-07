#!/usr/bin/env python3

from glob import glob
from os import execl
from os.path import basename, dirname, realpath
import re
from typing import Callable, Collection, Dict, List, NoReturn, Union
from sys import argv, stderr
# from .create.python import bootstrap_py

# Compute and store current script directory.
CSD = realpath(dirname(realpath(__file__)))


def usage(use: str = '', description: str = '', commands: Collection[str] = [], exit_code: Union[int, None] = 0) -> None:
  """Print usage and exit program with exit_code if it's an int."""
  print(
      f'Usage: {argv[0]}{f" {use}" if len(use) else ""}{" COMMAND" if len(commands) else ""}')
  if len(description) > 0:
    print('', description, sep='\n')
  if len(commands) > 0:
    print('', 'Available commands:', sep='\n')
    for command in commands:
      print(f'  {command}')
  if type(exit_code) is int:
    exit(exit_code)


def create(args: List[str]) -> NoReturn:
  """Execute a script from ./create/ folder."""
  commands = [re.sub(r'\.py', '', basename(s))
              for s in glob(f'{CSD}/create/*') if not s.endswith('__init__.py')]
  if len(args) == 0:
    usage('create',
          description=f'Execute a script from {CSD}/create/ folder.',
          commands=sorted(commands))
    exit(0)
  try:
    execl(f'{CSD}/create/{args[0]}.py', 'create', *args[1:])
  except Exception as e:
    print(f'{e}: "{CSD}/create/{args[0]}.py"', file=stderr)
    exit(1)


# Map of command names to handlers.
COMMANDS: Dict[str, Callable[[List[str]], NoReturn]] = {
    'create': create,
}

if __name__ == '__main__':
  # print usage and exit if no arguments.
  if len(argv) == 1:
    usage(commands=COMMANDS.keys())

  COMMANDS[argv[1]](argv[2:])

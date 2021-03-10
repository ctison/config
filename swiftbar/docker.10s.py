#!/usr/bin/env python3

import json, os, sys
from urllib.request import Request, urlopen
from subprocess import run

sys.path.append(os.path.join(os.path.dirname(__file__), '../py'))
from swiftbar import ansi
from swiftbar.utils import ft_print

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>


def ft_docker_ps():
  completed_process = run(['docker', 'ps', '-a', '--format', '{{json .}}'],
                          capture_output=True)
  if completed_process.returncode:
    print('Error: ', completed_process.returncode)
    return
  containers = []
  for line in str(completed_process.stdout, 'utf-8').splitlines():
    containers.append(json.loads(line))
  return containers


if __name__ == '__main__':

  containers = ft_docker_ps()
  ft_print(f'🐳 #{len(containers)}')
  ft_print('---')

  for c in containers:
    ft_print(f'{c["Names"]}')
    ft_print(
      f'-- {ansi.black}ID: {ansi.reset}{c["ID"]} | symbolize=false ansi=true')
    ft_print(
      f'-- {ansi.black}Names: {ansi.reset}{c["Names"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}Image: {ansi.reset}{c["Image"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}Command: {ansi.reset}{c["Command"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}Ports: {ansi.reset}{c["Ports"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}RunningFor: {ansi.reset}{c["RunningFor"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}Size: {ansi.reset}{c["Size"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}State: {ansi.reset}{c["State"]} | symbolize=false ansi=true'
    )
    ft_print(
      f'-- {ansi.black}Status: {ansi.reset}{c["Status"]} | symbolize=false ansi=true'
    )
    ft_print(f'{c["Status"]} {c["Image"]}')
    ft_print('---')

  ft_print(
    'Refresh | href="swiftbar://refreshplugin?name=github-review-requests" terminal=false'
  )

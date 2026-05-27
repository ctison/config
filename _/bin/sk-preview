#!/usr/bin/env nu

def main [path: path] {
  $path
  | path type
  | match $in {
    'file' => (bat --color=always $path)
    'dir' => (fd . $path)
  }
}

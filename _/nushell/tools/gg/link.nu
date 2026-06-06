const LINKS = [
  [src dst];
  [codex/* ~/.codex/]
]

export def main [] {
  for link in $LINKS {
    $cfg.DIR_ | path join $link.src | glob -S $in
    | ln -sfv -w ...$in ($link.dst | path expand)
  }
}

#!/usr/bin/env -S nu

def --wrapped main [...rest] {
  with-env {
    # cSpell:disable
    # Bold mode
    LESS_TERMCAP_md: (ansi red)
    # Reset
    LESS_TERMCAP_me: (ansi reset)
    # Exit standout mode
    LESS_TERMCAP_se: (ansi reset)
    # Begin standout mode
    LESS_TERMCAP_so: (ansi yellow_reverse)
    # Exit underline mode
    LESS_TERMCAP_ue: (ansi reset)
    # Begin underline mode
    LESS_TERMCAP_us: (ansi green)
    # cSpell:enable
  } {
    exec less -Rj.5 ...$rest
  }
}

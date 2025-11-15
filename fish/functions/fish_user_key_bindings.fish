# cSpell:words prevd nextd

function fish_user_key_bindings
  bind --erase --all --preset
  bind ''            self-insert
  bind enter         execute
  bind alt-enter     'alt-enter'
  bind ctrl-alt-s    'printf %s\n $o | fish_clipboard_copy'
  # bind shift-enter   execute
  # bind ctrl-enter    execute
  bind tab           complete
  bind ctrl-c        cancel-commandline
  bind ctrl-d        exit
  bind ctrl-s        pager-toggle-search
  bind shift-tab     complete-and-search
  bind backspace     backward-delete-char
  bind up            up-or-search
  bind down          down-or-search
  bind up            up-or-search
  bind right         forward-char
  bind left          backward-char
  bind shift-left    prevd-or-backward-word
  bind alt-left      prevd-or-backward-word
  bind shift-right   nextd-or-forward-word
  bind alt-right     nextd-or-forward-word
  bind escape        cancel
  bind ctrl-l        'status test-terminal-feature scroll-content-up && commandline -f scrollback-push' clear-screen
  bind ctrl-d        delete-or-exit
  bind ctrl-u        backward-kill-line
  bind ctrl-k        kill-line
  bind ctrl-w        backward-kill-path-component
  bind ctrl-e        end-of-line
  bind ctrl-a        beginning-of-line
  bind end           end-of-line
  bind home          beginning-of-line
  bind pageup        beginning-of-history
  bind pagedown      end-of-history
  bind space         self-insert expand-abbr
  bind delete        delete-char
  bind alt-backspace backward-kill-word
  bind ctrl-r        history-pager
end

umask 0077
set -gx SHELL fish
set fish_key_bindings fish_user_key_bindings
set fish_private_mode true

set fish_color_autosuggestion   777777
set fish_color_command          00FF00
set fish_color_comment          30BE30
set fish_color_cwd              green
set fish_color_cwd_root         red
set fish_color_end              FF7B7B
set fish_color_error            A40000
set fish_color_escape           cyan
set fish_color_history_current  cyan
set fish_color_host             -o cyan
set fish_color_match            cyan
set fish_color_normal           normal
set fish_color_operator         cyan
set fish_color_param            30BE30
set fish_color_quote            44FF44
set fish_color_redirection      7BFF7B
set fish_color_search_match     --background=purple
set fish_color_selection        --background=purple
set fish_color_status           red
set fish_color_user             -o green
set fish_color_valid_path       --underline


set __CONFIG_DIR (builtin path dirname (builtin path dirname (builtin path resolve (builtin status -f))))

fish_add_path -Pa \
  $__CONFIG_DIR/bin \
  ~/.local/bin /opt/homebrew/bin

if type -q mise 2>/dev/null
  if status is-interactive
    mise activate fish | source
  else
    mise activate fish --shims | source
  end
end

if status is-interactive
  function _cmd_exists -a COMMAND
    type -q $COMMAND 2>/dev/null
  end
  function _add_alias -a NAME COMMAND
    if _cmd_exists $COMMAND
      alias $NAME="$argv[2..-1]"
    end
  end

  if _cmd_exists starship
    starship init fish | source
  end

  alias rl='exec fish'

  if _cmd_exists gpg
    set -gx GPG_TTY (tty)
  end

  if _cmd_exists eza
    alias l='eza -lag --group-directories-first'
    alias t='l -T'
    alias ll='l -a'
  end
end

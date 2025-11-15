function alt-enter
  if test -n "$(commandline)"
    builtin commandline "set o ($(commandline))"
  else
    builtin commandline "set o ($(printf %s\n $history[1]))"
  end
  builtin commandline -a '; builtin printf %s\n $o'
  builtin commandline -f repaint
  builtin commandline -f execute
end

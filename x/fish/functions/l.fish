function l
  if test (uname) = Darwin
    ls -lhG $argv
  else if set -l isGNU (ls --version 2>&1 | grep GNU) && test -n "$isGNU"
    ls -lhv --color=auto --group-d $argv
  else
    ls -lhv --color=auto $argv
  end
end
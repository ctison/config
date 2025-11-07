# cSpell:words mkcd
function mkcd -a dir
  argparse -N 1 -X 1 -- $argv
  or return

  mkdir -p -- "$dir"
  cd -- "$dir"
end
complete -c mkcd -f

# cSpell:words mkcode
function mkcode -a dir
  argparse -N 1 -X 1 -- $argv
  or return

  mkdir -p -- "$dir"
  c "$dir"
end
complete -c mkcode -f

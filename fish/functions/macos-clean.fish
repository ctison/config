function macos-clean -a app
  argparse -N 1 -X 1 -- $argv
  or return

  switch "$app"
    case final_cut
      # cSpell:words ffuserdata
      rm -i -- ~/Library/ApplicationSupport/.ffuserdata
  end
end
complete -c macos-clean -f -a 'final_cut'

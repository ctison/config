# cSpell:words DCIM
function copy-photos -a dest
  argparse -N 1 -X 1 -- $argv
  or return
  adb pull '/storage/emulated/0/DCIM/Camera/' "$dest"
  adb pull '/storage/emulated/0/Pictures/Screenshots/' "$dest"
  adb shell 'rm -f -- /storage/emulated/0/DCIM/Camera/* || true'
  adb shell 'rm -f -- /storage/emulated/0/Pictures/Screenshots/* || true'
  display-notification '🎥 Copy Photos' 'Finished successfully 🚀'
end
complete -c copy-photos -f -a '(__fish_complete_directories)'

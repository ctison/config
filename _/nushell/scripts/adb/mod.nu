use ../ux

export def pull-medias [dest: path]: nothing -> nothing {
  # cSpell:ignore DCIM
  adb pull /storage/emulated/0/DCIM/Camera/ $dest
  adb pull /storage/emulated/0/Pictures/Screenshots/ $dest
  adb shell 'rm -f -- /storage/emulated/0/DCIM/Camera/* || true'
  adb shell 'rm -f -- /storage/emulated/0/Pictures/Screenshots/* || true'
  ux display-notification '🎥 Copy Photos' 'Finished successfully 🚀'
}

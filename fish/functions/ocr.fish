# cSpell:words screencapture tesseract
function ocr
  set -l img (mktemp).png
  /usr/sbin/screencapture -i -- "$img"
  tesseract "$img" stdout | pbcopy
  rm -f -- "$img"
end
complete -c ocr -f

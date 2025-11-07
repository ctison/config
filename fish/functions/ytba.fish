# cSpell:words ytba bestaudio
function ytba -w youtube-dl
  youtube-dl -f bestaudio -o '%(channel)s - %(title)s.%(ext)s' $argv
end
complete -c ytba -f

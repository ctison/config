function display-notification -a title -a message
  if test (uname) = "Darwin"
    osascript -e "display notification \"$message\" with title \"$title\""
  else if test (uname) = "Linux"
    notify-send "$title" "$message"
  end
  echo "$title: $message"
end
complete -c display-notification -f

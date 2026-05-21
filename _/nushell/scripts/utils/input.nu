export def secret [name?: string] {
  let name = $name | default {''}
  if ('"' in $name) {
    error make $'$name cant contain `"`: ($name)'
  }
  osascript -e $'
  try
    set result to display dialog "($name)" default answer "" buttons {"Cancel", "OK"} default button "OK" with hidden answer
    set txt to text returned of result
    return txt
  on error number -128
      return ""
  end try
  '
}

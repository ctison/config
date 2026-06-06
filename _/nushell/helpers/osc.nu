export def copy []: any -> any {
  tee {
    match ($in | describe) {
      string => $in
      _ => { to text }
    }
    | ansi -o $"52;c;($in | encode base64)\a"
    | print -n
  }
}

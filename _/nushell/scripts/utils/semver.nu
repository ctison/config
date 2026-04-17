export def main []: string -> table {
  parse -r '^(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)(?:-(?P<channel>w+))?$'
}

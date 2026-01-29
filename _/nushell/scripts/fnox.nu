export def run [profile: string, closure: closure]: any -> any {
  with-env (^fnox -P $profile export -f json | from json | $in.secrets) $closure
}

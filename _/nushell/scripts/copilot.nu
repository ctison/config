export def research [] {
  ls -a ~/.copilot/session-state/*/research/*.md
  | update name {
    str replace -r $'^($env.HOME | str escape-regex)' '~'
    | fmt link $in
  }
}

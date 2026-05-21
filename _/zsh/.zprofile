# if [[ $TERM_PROGRAM = vscode ]]; then
#   exec nu
# fi

# Append to PATH if directory exists and not already in PATH
append_to_path() {
  for dir in "$@"; do
    if test -d "$dir" && [[ ":$PATH:" != *":$dir:"* ]]; then
      export PATH="$PATH:$dir"
    fi
  done
}

append_to_path \
  /opt/homebrew/bin \
  ~/.bun/bin

eval "$(mise activate zsh)"

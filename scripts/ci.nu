def main [] {
  rm -rf ($env.FILE_PWD)/../node_modules
  bun install --frozen-lockfile
  bun run lint
  bun run test
}

# Guidelines

This monorepo uses `mise` to install root tools, you should fail if you don't have access to `mise`.
Prefix commands managed by `mise` with `mise x --`, eg. `mise x -- bun install`.
This monorepo uses `bun`.

# Workflow

`mise install` -> install root tools
`mise update` -> update root tools
`bun install` -> install bun deps
`bun update -r` -> update bun deps

# Map

`scripts/` -> maintainance scripts
`_/.agents/` -> cross configurations for ai coding tools
`_/bin/` -> runnable scripts added to $env.PATH
`_/*/` -> configurations for tools
`pkgs/utils/` -> `@ctison/utils` shared typescript utils

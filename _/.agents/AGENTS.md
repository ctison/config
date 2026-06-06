# Guidelines

Ask review before adding dependencies.
Use latest version when adding dependencies.
When in a monorepo, prefer defining dependencies versions at the root:

- For `bun` deps, set them in the root `package.json `bun` catalogs. Ask review when creating a new named catalog.
- For `cargo` deps, set them as `workspace.dependencies` in the root `Cargo.toml`.

Prefer typescript over javascript.
Add single line comments to every functions.

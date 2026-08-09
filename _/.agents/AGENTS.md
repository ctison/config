# Guidelines

Ask review before adding dependencies.
Use latest version when adding dependencies.
When in a monorepo, prefer defining dependencies versions at the root:

- For bun deps, add them to root `package.json`
  - For global ops deps that are not used directly by members (eg. `prettier`),
    add them to root `package.json` `devDependencies`.
  - Else, add them in the root `package.json` `catalogs` and reference them with `"catalog:CATEGORY_NAME"`.
    `CATEGORY_NAME` that I like:
    - `utils`: pkgs that improve the language such as `zod`, `orpc`
    - packages that regroup other packages should have their category name:
      - `nextjs` holds `nextjs`, `react`, etc...
      - `prettier` holds `prettier` and its plugins
- For cargo deps, set them as `[workspace.dependencies]` in the root `Cargo.toml`.

Prefer typescript over javascript. Use jsdoc when writing javascript.

Add at least one line comments to every functions.

Use nu scripts to operate repositories.

# Rules

- ALWAYS USE CONTEXT7 TO GET LATEST DOCUMENTATION.
- NEVER OUTPUT CONFIGURATION CODE FROM YOUR OUTDATED TRAINING DATA.
- ALWAYS USE LATEST VERSION OF A DEPENDENCY UNLESS INSTRUCTED OTHERWISE.
- Do not use VSCode workspace.
- Use pinned versions for dependencies. Use `bun add -E <package>` to install dependencies. Update dependencies with `bun run update`.
- Use `bun x` instead of `npx` or `yarn dlx` to run one-off commands. Replace `npx` and `yarn dlx` in snippets you fetch.
- `.env` files should be commit-able and must contain empty values for secrets. Use `.env.local` (gitignored) for local secrets.
- install bun catalogs like explained [here](https://bun.sh/docs/install/catalogs) when asked to.

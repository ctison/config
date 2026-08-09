/** @type {import('lint-staged').Configuration} */
export default {
  'package.json': 'sort-package-json',
  '*.toml': 'tombi lint --error-on-warnings',
  '*': () => 'bun run lint',
};

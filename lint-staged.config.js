/** @type {import('lint-staged').Configuration} */
export default {
  'package.json': 'sort-package-json',
  '*': () => 'bun run lint',
};

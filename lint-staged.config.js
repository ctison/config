/** @type {import('lint-staged').Configuration} */
export default {
  'package.json': 'sort-package-json',
  '*': () => 'mise run lint',
};

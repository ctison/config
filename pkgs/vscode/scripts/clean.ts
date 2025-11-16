import { clean } from '@ctison/utils';
import { packageDir } from './_';

if (import.meta.main) {
  await clean({
    packageDir,
    globs: Bun.argv.length > 2 ? Bun.argv.slice(2) : undefined,
  });
}

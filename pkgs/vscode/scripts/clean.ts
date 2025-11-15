import { clean } from '@ctison/utils';

if (import.meta.main) {
  await clean({ globs: Bun.argv.length > 2 ? Bun.argv.slice(2) : undefined });
}

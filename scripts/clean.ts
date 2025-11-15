import { rm } from 'node:fs/promises';
import { parseArgs } from 'node:util';

const {
  values: { apply },
} = parseArgs({
  args: Bun.argv.splice(2),
  options: {
    apply: {
      type: 'boolean',
      short: 'a',
    },
  },
});

const globsToClean = [
  'node_modules/',
  '.turbo/',
  '**/node_modules/',
  '**/.turbo/',
];

const promises: Promise<unknown>[] = [];

if (apply) {
  await Bun.$`bun run clean`;
}

const paths =
  Bun.$`git ls-files -o --directory -x .vscode-test/ ${globsToClean}`.lines();

for await (const path of paths) {
  if (path.length > 0) {
    promises.push(
      Promise.try(async () => {
        console.log(`>>> Deleting ${apply ? '' : '(dry run)'}: '${path}'`);
        if (apply) {
          await rm(path, { recursive: true, force: true });
        }
      }),
    );
  }
}

await Promise.allSettled(promises);

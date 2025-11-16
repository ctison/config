import { parseArgs } from 'node:util';
import * as utils from '@ctison/utils';
import { packageDir } from './_';

export namespace build {
  export type Options = {
    bundle?: boolean;
  };
}

export async function build(opts?: build.Options) {
  if (opts?.bundle) {
    await utils.clean({ packageDir, globs: ['dist/bundle/'] });
    await utils.build({
      packageDir,
      tsconfigPath: null,
      buildOpts: {
        target: 'node',
        outdir: 'dist/bundle',
        entrypoints: ['src/index.ts'],
        packages: 'bundle',
        sourcemap: 'none',
        drop: ['console'],
        minify: true,
        define: {
          'process.node.ENV': '"production"',
        },
      },
    });
  } else {
    await utils.clean({ packageDir, globs: ['dist/src/'] });
    await utils.build({
      packageDir,
      tsconfigPath: null,
      includeTestFiles: true,
      buildOpts: {
        target: 'node',
      },
    });
  }
}

if (import.meta.main) {
  const {
    values: { bundle },
  } = parseArgs({
    options: {
      bundle: { type: 'boolean' },
    },
  });
  await build({ bundle });
}

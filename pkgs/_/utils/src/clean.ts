import { rm } from 'node:fs/promises';
import { Glob } from 'bun';
import { ctx } from '.';

export namespace clean {
  export type Options = {
    packageDir?: string;
    globs?: string[];
  };
}

export async function clean(opts?: clean.Options) {
  const packageDir = opts?.packageDir ?? ctx.packageDir;
  await Promise.all(
    (opts?.globs ?? clean.defaultGlobs).map(async (glob) => {
      const promises: Promise<void>[] = [];
      for await (const match of new Glob(glob).scan({
        cwd: packageDir,
        dot: true,
        onlyFiles: false,
      })) {
        promises.push(rm(match, { recursive: true, force: true }));
      }
      await Promise.all(promises);
    }),
  );
}

export namespace clean {
  export const defaultGlobs = ['dist/', '*.tgz', '*.vsix'];
}

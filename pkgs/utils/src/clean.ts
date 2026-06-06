import { rm } from 'node:fs/promises';
import { Glob } from 'bun';

export namespace clean {
  export type Options = {
    packageDir: string;
    globs?: string[];
  };
}

export async function clean({ packageDir, ...opts }: clean.Options) {
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

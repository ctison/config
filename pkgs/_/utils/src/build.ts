import { Glob } from 'bun';

export namespace build {
  export type Options = {
    packageDir: string;
    tsconfigPath?: string | null;
    includeTestFiles?: boolean;
    buildOpts?: Partial<Bun.BuildConfig>;
  };
}

export async function build({ packageDir, ...opts }: build.Options) {
  if (opts?.tsconfigPath !== null) {
    const tsconfigPath =
      opts?.tsconfigPath ?? `${packageDir}/tsconfig.build.json`;
    await Bun.$`tsc --build ${tsconfigPath}`;
  }

  const include = new Glob(
    `${packageDir}/${opts?.includeTestFiles ? '{src,tests}' : 'src'}/**/*.{ts,tsx}`,
  );
  const exclude = /\.test\./;
  const entrypoints: string[] = [];
  for await (const file of include.scan({ cwd: packageDir })) {
    if (opts?.includeTestFiles || !exclude.test(file)) {
      entrypoints.push(file);
    }
  }

  const commitHash = await getGitCommitHash().then((s) => `"${s.trim()}"`);

  await Bun.build({
    entrypoints,
    root: packageDir,
    outdir: './dist',
    target: 'browser',
    format: 'esm',
    external: ['*'],
    drop: [],
    env: 'disable',
    splitting: false,
    packages: 'external',
    sourcemap: 'linked',
    banner: undefined,
    footer: undefined,
    jsx: undefined,
    minify: {
      syntax: true,
    },
    tsconfig: undefined,
    loader: {},
    define: {
      // biome-ignore-start lint/style/useNamingConvention: ...
      ___COMMIT_HASH___: commitHash,
      // biome-ignore-end lint/style/useNamingConvention: ...
    },
    ...opts?.buildOpts,
  });
}

export function getGitCommitHash() {
  return Bun.$`git rev-parse HEAD`.text();
}

import path from 'node:path';
import { getDomain, getRepositoryUrl } from '.';

export namespace findNearestPackageJson {
  export type Options = {
    /**
     * Where to search package.json from.
     *
     * @default process.cwd()
     */
    from?: string;
    /**
     * If true, returns the directory containing package.json instead of the
     * path to package.json.
     *
     * @default false
     */
    shouldReturnDir?: boolean;
    /**
     * If true, search for a package.json with a workspace field.
     *
     * @default false
     */
    shouldBeWorkspace?: boolean;
  };
}

export async function findNearestPackageJson({
  from = process.cwd(),
  shouldReturnDir = false,
  shouldBeWorkspace = false,
}: findNearestPackageJson.Options = {}): Promise<string> {
  const _from = path.resolve(from);
  from = _from;
  while (true) {
    const packageJsonPath = path.join(from, 'package.json');
    if (await Bun.file(packageJsonPath).exists()) {
      if (shouldBeWorkspace) {
        const packageJson = await Bun.file(packageJsonPath).json();
        if ('workspaces' in packageJson) {
          return shouldReturnDir ? from : packageJsonPath;
        }
      } else {
        return shouldReturnDir ? from : packageJsonPath;
      }
    }
    const dir = path.dirname(from);
    if (dir === from) {
      throw new Error(`Could not find package.json from ${_from}`);
    }
    from = dir;
  }
}

export namespace getRelativePathToRootPackageJson {
  export type Options = Pick<findNearestPackageJson.Options, 'from'>;
}

export async function getRelativePathToRootPackageJson({
  from = process.cwd(),
}: getRelativePathToRootPackageJson.Options = {}): Promise<string> {
  const rootPackagePath = await findNearestPackageJson({
    from,
    shouldReturnDir: true,
    shouldBeWorkspace: true,
  });
  return path.relative(rootPackagePath, from);
}

/**
 * @see https://docs.npmjs.com/cli/configuring-npm/package-json
 * @see https://code.visualstudio.com/api/references/extension-manifest
 */
export type PackageJson = {
  name: string;
  version?: string;
  repository?: {
    type: 'git';
    url: string;
    directory?: string;
  };
  scripts?: unknown;
  devDependencies?: Record<string, string>;
  bugs?: {
    url: string;
    email: string;
  };
  license: string;
  engines?: {
    vscode?: string;
  };
};

export async function preparePackageJsonForRelease(
  packageJson: PackageJson,
  email?: string,
): Promise<PackageJson> {
  const repositoryUrl = await getRepositoryUrl();

  packageJson.repository = {
    type: 'git',
    url: repositoryUrl,
    directory: await getRelativePathToRootPackageJson(),
  };

  packageJson.bugs = {
    url: repositoryUrl.replace(/\.git$/, '').concat('/issues'),
    email: getDomain(email ?? packageJson.name.split('/').at(-1)!),
  };

  packageJson.license = 'MIT';

  delete packageJson.scripts;
  delete packageJson.devDependencies;

  return packageJson;
}

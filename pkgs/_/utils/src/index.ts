import path from 'node:path';
import { findNearestPackageJson } from './package-json';

export * from './build';
export * from './clean';
export * from './git';
export * from './package-json';
export * from './vars';

export const ctx = await (async () => {
  const packageJsonPath =
    Bun.env['npm_package_json'] ?? (await findNearestPackageJson());
  return {
    packageJsonPath,
    packageDir: path.dirname(packageJsonPath),
  };
})();

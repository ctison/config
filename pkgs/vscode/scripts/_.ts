import path from 'node:path';

export const packageDir = path.resolve(import.meta.dir, '..');

export const packageJsonPath = path.join(packageDir, 'package.json');

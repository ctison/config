import path from 'node:path';
import { runTests } from '@vscode/test-electron';
import { packageDir } from './_';

if (import.meta.main) {
  const extensionDevelopmentPath = packageDir;
  const extensionTestsPath = path.resolve(
    extensionDevelopmentPath,
    'dist',
    'src',
    'index.test.js',
  );

  await runTests({
    extensionDevelopmentPath,
    extensionTestsPath,
  });
}

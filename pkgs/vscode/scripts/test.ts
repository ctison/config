import path from 'node:path';
import { ctx } from '@ctison/utils';
import { runTests } from '@vscode/test-electron';

if (import.meta.main) {
  const extensionDevelopmentPath = ctx.packageDir;
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

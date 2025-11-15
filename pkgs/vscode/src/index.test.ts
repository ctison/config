import assert from 'node:assert/strict';
import { after, test } from 'node:test';
import { tap } from 'node:test/reporters';
import * as vscode from 'vscode';

export async function run(): Promise<void> {
  test
    .run({
      concurrency: true,
      cwd: import.meta.dirname,
      files: ['**/*.test.js'],
      timeout: 30_000,
    })
    .on('test:fail', () => {
      process.exitCode = 1;
    })
    .compose(tap)
    .pipe(process.stdout);
}

after(() => {
  vscode.window.showInformationMessage('All tests done!');
});

test('Sample test', () => {
  assert.strictEqual(-1, [1, 2, 3].indexOf(5));
  assert.strictEqual(-1, [1, 2, 3].indexOf(0));
});

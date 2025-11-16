import * as utils from '@ctison/utils';
import { packageJsonPath } from './_';

export async function main(): Promise<number> {
  console.debug(`>>> Loading ${packageJsonPath}`);

  if ((await utils.hasUnstagedModifications(packageJsonPath)).length > 0) {
    console.error(`Error: ${packageJsonPath} has unstaged modifications.`);
    return 1;
  }

  const packageJson = await utils.preparePackageJsonForRelease(
    await Bun.file(packageJsonPath).json(),
  );

  console.debug('>>> Updated package.json');
  console.dir(packageJson, { depth: null });

  await Bun.write(packageJsonPath, `${JSON.stringify(packageJson, null, 2)}\n`);

  console.debug('>>> Packing...');
  try {
    await Bun.$`vsce pack --no-git-tag-version --no-update-package-json \
      --no-dependencies --skip-license --out out.vsix`;
  } finally {
    await utils.discardUnstagedModifications(packageJsonPath);
  }

  return 0;
}

if (import.meta.main) {
  process.exit(await main());
}

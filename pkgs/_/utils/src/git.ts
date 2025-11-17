export async function hasUnstagedModifications(
  ...files: string[]
): Promise<string[]> {
  const results = await Promise.all(
    files.map(async (file) => {
      const gitStatus = await Bun.$`git status --porcelain ${file}`.text();
      if (gitStatus.match(/^.M/)) {
        return file;
      }
      return null;
    }),
  );
  return results.filter((file) => typeof file === 'string');
}

export async function discardUnstagedModifications(
  ...files: string[]
): Promise<void> {
  await Bun.$`git checkout -- ${files}`;
}

export async function getRepositoryUrl(name = 'origin'): Promise<string> {
  return await Bun.$`git remote get-url ${name}`.text().then((s) => s.trim());
}

export async function isGitRepository(): Promise<boolean> {
  return await Bun.$`git rev-parse --is-inside-work-tree`
    .quiet()
    .then(() => true)
    .catch(() => false);
}

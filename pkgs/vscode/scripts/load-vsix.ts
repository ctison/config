if (import.meta.main) {
  const program = Bun.argv[2]
    ? Bun.argv[2]
    : // cSpell:ignore askpass
      ['EDITOR', 'VISUAL', 'TERM_PROGRAM_VERSION', 'GIT_ASKPASS'].some((s) =>
          Bun.env[s]?.includes('insiders'),
        )
      ? 'code-insiders'
      : 'code';
  try {
    await Bun.$`${program} --install-extension ./out.vsix`;
  } catch (e) {
    console.error(`Failed to install extension: ${e}`);
  }
}

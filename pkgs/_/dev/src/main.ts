import { program } from 'commander';
import packageJson from '../package.json' with { type: 'json' };

program.name(packageJson.name);

export async function main(): Promise<number> {
  program.parse();

  return 0;
}

if (import.meta.main) {
  process.exitCode = await main();
}

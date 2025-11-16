import { resolve } from 'node:path';

export const rootDirPath = resolve(`${import.meta.dir}/../..`);
export const dataDirPath = resolve(`${rootDirPath}/x/`);

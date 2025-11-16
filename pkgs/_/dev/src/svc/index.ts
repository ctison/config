import { Layer } from 'effect';
import { Docker } from './Docker';
import { Surreal } from './Surreal';

export * from './Docker';
export * from './Surreal';

export const MainLive = Layer.mergeAll(Docker.Default, Surreal.Default);

import { NodeRuntime } from '@effect/platform-node';
import { Console, Effect } from 'effect';
import { Docker, MainLive, Surreal } from './svc';

if (import.meta.main) {
  NodeRuntime.runMain(
    Effect.gen(function* () {
      {
        const surreal = yield* Surreal.client;
        yield* Console.log('Surreal Client:', surreal.status);
        const docker = yield* Docker.client;
        const images = yield* Effect.tryPromise(async () => docker.imageList());
        yield* Console.log('Docker Images:', images.length);
      }
      {
        const surreal = yield* Surreal.client;
        yield* Console.log('Surreal Client:', surreal.status);

        const docker = yield* Docker.client;
        const images = yield* Effect.tryPromise(async () => docker.imageList());
        yield* Console.log('Docker Images:', images.length);
      }
    }).pipe(Effect.provide(MainLive)),
  );
}

import { DockerClient } from '@docker/node-sdk';
import { Console, Effect, Scope } from 'effect';

export class Docker extends Effect.Service<Docker>()('Docker', {
  accessors: true,
  scoped: Effect.gen(function* () {
    const scope = yield* Effect.scope;
    const scoped = Scope.extend(scope);
    yield* Effect.log(scoped);

    return {
      client: Effect.acquireRelease(
        Effect.gen(function* () {
          yield* Effect.log('Initializing Docker Client');
          return yield* Effect.tryPromise(() =>
            DockerClient.fromDockerConfig(),
          );
        }),
        (client) =>
          Effect.gen(function* () {
            yield* Effect.log('Finalizing Docker Client');
            yield* Effect.tryPromise(() => client.close()).pipe(
              Effect.catchAll(Console.error),
            );
          }),
      ).pipe(Scope.extend(scope)),
    };
  }),
}) {}

// interface Options {}

// export const make = (options?: Options) => Effect.acquireRelease();

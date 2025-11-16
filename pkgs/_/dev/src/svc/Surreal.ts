import { Effect, Option, SynchronizedRef } from 'effect';
import { Surreal as SurrealClient } from 'surrealdb';

export class Surreal extends Effect.Service<Surreal>()('Surreal', {
  accessors: true,
  scoped: Effect.gen(function* () {
    const result = {
      _client: yield* SynchronizedRef.make(Option.none<SurrealClient>()),
      get client() {
        return SynchronizedRef.updateSomeAndGetEffect(
          this._client,
          Option.match({
            onNone: () =>
              Option.some(
                Effect.gen(function* () {
                  yield* Effect.log('Initializing Surreal Client');
                  const client = yield* Effect.try(() => new SurrealClient());
                  return Option.some(client);
                }),
              ),
            onSome: () => Option.none(),
          }),
        ).pipe(Effect.andThen(Option.getOrThrow));
      },
    };
    yield* Effect.addFinalizer(() =>
      SynchronizedRef.updateSomeEffect(
        result._client,
        Option.match({
          onSome: (client) =>
            Option.some(
              Effect.gen(function* () {
                yield* Effect.log('Finalizing Surreal Client');
                yield* Effect.tryPromise(() => client.close());
                return Option.none();
              }),
            ),
          onNone: () => Option.none(),
        }),
      ).pipe(Effect.catchAll(Effect.logError)),
    );
    return result;
  }),
}) {}

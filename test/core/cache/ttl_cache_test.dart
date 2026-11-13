import 'dart:async';

import 'package:coding_dorado/core/cache/ttl_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late TtlCache<String, int> cache;
  late int calls;

  Future<int> fetch() async => ++calls;

  setUp(() {
    now = DateTime(2026, 11, 13, 12);
    calls = 0;
    cache = TtlCache(ttl: const Duration(seconds: 60), now: () => now);
  });

  test(
    'dentro del TTL devuelve el valor cacheado sin volver a pedir',
    () async {
      expect(await cache.get('k', fetch), 1);
      now = now.add(const Duration(seconds: 59));
      expect(await cache.get('k', fetch), 1);
      expect(calls, 1);
    },
  );

  test('al vencer el TTL vuelve a pedir', () async {
    await cache.get('k', fetch);
    now = now.add(const Duration(seconds: 60));
    expect(await cache.get('k', fetch), 2);
    expect(calls, 2);
  });

  test('las claves son independientes', () async {
    await cache.get('a', fetch);
    await cache.get('b', fetch);
    expect(calls, 2);
  });

  test('dos llamadas simultáneas comparten una sola petición', () async {
    final completer = Completer<int>();
    var started = 0;
    Future<int> slow() {
      started++;
      return completer.future;
    }

    final first = cache.get('k', slow);
    final second = cache.get('k', slow);
    completer.complete(7);

    expect(await first, 7);
    expect(await second, 7);
    expect(started, 1);
  });

  test('los errores no se cachean', () async {
    var attempt = 0;
    Future<int> flaky() async {
      attempt++;
      if (attempt == 1) throw StateError('falló');
      return 42;
    }

    await expectLater(cache.get('k', flaky), throwsStateError);
    expect(await cache.get('k', flaky), 42);
    expect(attempt, 2);
  });

  test('forceRefresh ignora la entrada vigente', () async {
    await cache.get('k', fetch);
    expect(await cache.get('k', fetch, forceRefresh: true), 2);
  });

  test('peek no dispara peticiones y respeta el TTL', () async {
    expect(cache.peek('k'), isNull);
    await cache.get('k', fetch);
    expect(cache.peek('k'), 1);
    now = now.add(const Duration(minutes: 2));
    expect(cache.peek('k'), isNull);
    expect(calls, 1);
  });

  test('invalidate borra una clave o todas', () async {
    await cache.get('a', fetch);
    await cache.get('b', fetch);
    cache.invalidate('a');
    expect(cache.peek('a'), isNull);
    expect(cache.peek('b'), isNotNull);
    cache.invalidate();
    expect(cache.peek('b'), isNull);
  });
}

import 'dart:async';

/// Caché en memoria con vencimiento por entrada.
///
/// - Si hay una petición en curso para una clave, las llamadas siguientes
///   esperan ese mismo resultado en lugar de lanzar otra.
/// - Los errores no se cachean.
/// - `forceRefresh` ignora la entrada guardada (pero reutiliza una petición
///   que ya esté en curso, porque su resultado es igual de fresco).
class TtlCache<K, V> {
  TtlCache({required this.ttl, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Duration ttl;
  final DateTime Function() _now;
  final Map<K, _Entry<V>> _entries = {};
  final Map<K, Future<V>> _inFlight = {};

  Future<V> get(
    K key,
    Future<V> Function() fetch, {
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = peek(key);
      if (cached != null) return Future.value(cached);
    }
    final pending = _inFlight[key];
    if (pending != null) return pending;

    final request = _fetch(key, fetch);
    _inFlight[key] = request;
    return request;
  }

  /// Valor vigente para [key], sin disparar peticiones.
  V? peek(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_now().difference(entry.storedAt) >= ttl) return null;
    return entry.value;
  }

  void invalidate([K? key]) {
    if (key == null) {
      _entries.clear();
    } else {
      _entries.remove(key);
    }
  }

  Future<V> _fetch(K key, Future<V> Function() fetch) async {
    try {
      final value = await fetch();
      _entries[key] = _Entry(value, _now());
      return value;
    } finally {
      unawaited(_inFlight.remove(key));
    }
  }
}

final class _Entry<V> {
  const _Entry(this.value, this.storedAt);

  final V value;
  final DateTime storedAt;
}

import 'package:equatable/equatable.dart';

/// Fuente de datos de la pestaña El Dorado.
enum EldoradoSource {
  /// `GET /api/prices`: precio indicativo de su libro P2P.
  prices,

  /// `GET …/orderbook/public/recommendations`: oferta concreta (Fase 10).
  orderbook,
}

/// Configuración de entorno. Los valores viven en `.env` (ver `.env.example`)
/// y llegan con `--dart-define-from-file=.env`: el código no tiene URLs.
final class AppConfig extends Equatable {
  const AppConfig({
    required this.eldoradoApiUrl,
    required this.criptoyaApiUrl,
    this.eldoradoSource = EldoradoSource.prices,
    this.orderbookApiUrl = '',
  });

  factory AppConfig.fromEnvironment() => AppConfig(
    eldoradoApiUrl: const String.fromEnvironment('ELDORADO_API_URL'),
    criptoyaApiUrl: const String.fromEnvironment('CRIPTOYA_API_URL'),
    eldoradoSource: parseEldoradoSource(
      const String.fromEnvironment('ELDORADO_SOURCE'),
    ),
    // El analizador evalúa fromEnvironment sin el .env (vacío) y lo toma
    // como el valor por defecto.
    // ignore: avoid_redundant_argument_values
    orderbookApiUrl: const String.fromEnvironment('API_URL'),
  );

  /// URL base de `/prices` (`ELDORADO_API_URL`). Obligatoria.
  final String eldoradoApiUrl;

  /// URL base de CriptoYa (`CRIPTOYA_API_URL`). Obligatoria.
  final String criptoyaApiUrl;

  /// `ELDORADO_SOURCE`; `prices` si falta.
  final EldoradoSource eldoradoSource;

  /// URL completa del endpoint `recommendations` (`API_URL`, Fase 10).
  final String orderbookApiUrl;

  /// Claves obligatorias que faltan o están vacías.
  List<String> get missingKeys => [
    if (eldoradoApiUrl.trim().isEmpty) 'ELDORADO_API_URL',
    if (criptoyaApiUrl.trim().isEmpty) 'CRIPTOYA_API_URL',
  ];

  /// Lanza [MissingConfigException] si falta alguna clave obligatoria.
  void ensureComplete() {
    final missing = missingKeys;
    if (missing.isNotEmpty) throw MissingConfigException(missing);
  }

  /// Valores desconocidos o vacíos vuelven a [EldoradoSource.prices].
  static EldoradoSource parseEldoradoSource(String raw) {
    for (final source in EldoradoSource.values) {
      if (source.name == raw.trim().toLowerCase()) return source;
    }
    return EldoradoSource.prices;
  }

  @override
  List<Object?> get props => [
    eldoradoApiUrl,
    criptoyaApiUrl,
    eldoradoSource,
    orderbookApiUrl,
  ];
}

/// Falta configuración obligatoria: la app se ejecutó sin el `.env`.
final class MissingConfigException implements Exception {
  const MissingConfigException(this.keys);

  final List<String> keys;

  @override
  String toString() =>
      'MissingConfigException: faltan ${keys.join(', ')}. Copia .env.example '
      'a .env, completa los valores y ejecuta con '
      '--dart-define-from-file=.env.';
}

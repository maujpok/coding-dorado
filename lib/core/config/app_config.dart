import 'package:equatable/equatable.dart';

/// Fuente de datos de la pestaña El Dorado.
enum EldoradoSource {
  /// `GET /api/prices`: precio indicativo de su libro P2P.
  prices,

  /// `GET …/orderbook/public/recommendations`: oferta concreta (Fase 10).
  orderbook,
}

/// Configuración de entorno, leída de `--dart-define`.
final class AppConfig extends Equatable {
  const AppConfig({
    required this.eldoradoApiUrl,
    required this.criptoyaApiUrl,
    required this.eldoradoSource,
    required this.orderbookApiUrl,
  });

  /// Valores por defecto: las APIs públicas de cada proveedor.
  const AppConfig.defaults()
    : eldoradoApiUrl = defaultEldoradoApiUrl,
      criptoyaApiUrl = defaultCriptoyaApiUrl,
      eldoradoSource = EldoradoSource.prices,
      orderbookApiUrl = '';

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      eldoradoApiUrl: const String.fromEnvironment(
        'ELDORADO_API_URL',
        defaultValue: defaultEldoradoApiUrl,
      ),
      criptoyaApiUrl: const String.fromEnvironment(
        'CRIPTOYA_API_URL',
        defaultValue: defaultCriptoyaApiUrl,
      ),
      eldoradoSource: parseEldoradoSource(
        const String.fromEnvironment('ELDORADO_SOURCE'),
      ),
      orderbookApiUrl: const String.fromEnvironment('API_URL'),
    );
  }

  static const defaultEldoradoApiUrl = 'https://api.eldorado.io/api';
  static const defaultCriptoyaApiUrl = 'https://criptoya.com/api';

  final String eldoradoApiUrl;
  final String criptoyaApiUrl;
  final EldoradoSource eldoradoSource;

  /// URL completa del endpoint `recommendations` (Fase 10).
  final String orderbookApiUrl;

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

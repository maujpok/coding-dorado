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
    required this.useMock,
    required this.mockScenarioEldorado,
    required this.mockScenarioCriptoya,
    required this.mockLatency,
    required this.eldoradoSource,
    required this.orderbookApiUrl,
  });

  /// Valores por defecto: APIs reales, sin mock.
  const AppConfig.defaults()
    : eldoradoApiUrl = defaultEldoradoApiUrl,
      criptoyaApiUrl = defaultCriptoyaApiUrl,
      useMock = false,
      mockScenarioEldorado = 'success',
      mockScenarioCriptoya = 'success',
      mockLatency = const Duration(milliseconds: 600),
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
      useMock: const bool.fromEnvironment('USE_MOCK'),
      mockScenarioEldorado: const String.fromEnvironment(
        'MOCK_SCENARIO_ELDORADO',
        defaultValue: 'success',
      ),
      mockScenarioCriptoya: const String.fromEnvironment(
        'MOCK_SCENARIO_CRIPTOYA',
        defaultValue: 'success',
      ),
      mockLatency: const Duration(
        milliseconds: int.fromEnvironment(
          'MOCK_LATENCY_MS',
          defaultValue: 600,
        ),
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
  final bool useMock;
  final String mockScenarioEldorado;
  final String mockScenarioCriptoya;
  final Duration mockLatency;
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
    useMock,
    mockScenarioEldorado,
    mockScenarioCriptoya,
    mockLatency,
    eldoradoSource,
    orderbookApiUrl,
  ];
}

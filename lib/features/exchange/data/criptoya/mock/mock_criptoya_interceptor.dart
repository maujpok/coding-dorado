import 'package:coding_dorado/features/exchange/data/eldorado/mock/mock_prices.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

enum CriptoYaMockScenario {
  success,

  /// Todos los exchanges en 0.
  noOffers,

  /// HTTP 429.
  rateLimited,

  /// HTTP 500.
  serverError,
  timeout,

  /// HTML en lugar de JSON.
  malformed
  ;

  static CriptoYaMockScenario parse(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'no_offers' => noOffers,
        'rate_limited' => rateLimited,
        'server_error' => serverError,
        'timeout' => timeout,
        'malformed' => malformed,
        _ => success,
      };
}

/// Responde `GET …/{coin}/{fiat}/{volumen}` con la forma real de CriptoYa:
/// 4 exchanges, tres alrededor del valor objetivo y uno sin ofertas (0).
///
/// Valores objetivo (la mediana), elegidos para que la comparación tenga un
/// ganador distinto según la dirección:
/// - `bid` = `SELL` de El Dorado × 1.01 (CriptoYa conviene al vender).
/// - `ask` = `BUY` de El Dorado × 1.01 (El Dorado conviene al comprar);
///   VES `ask` = 25.75, porque El Dorado no tiene VES en `BUY`.
/// - USDC = USDT × 0.998.
class MockCriptoYaInterceptor extends Interceptor {
  MockCriptoYaInterceptor({
    this.scenario = CriptoYaMockScenario.success,
    this.latency = Duration.zero,
  });

  final CriptoYaMockScenario scenario;
  final Duration latency;

  static final Decimal _criptoyaSpread = Decimal.parse('1.01');
  static final Decimal _usdcFactor = Decimal.parse('0.998');
  static final Decimal _vesAsk = Decimal.parse('25.75');
  static final List<Decimal> _spreads = [
    Decimal.parse('0.995'),
    Decimal.one,
    Decimal.parse('1.005'),
  ];
  static const _exchanges = ['binancep2p', 'bybitp2p', 'okexp2p', 'bitgetp2p'];

  /// Mediana que el mock devuelve para `bid` (vender) y `ask` (comprar).
  static ({Decimal bid, Decimal ask})? targetsFor(String coin, String fiat) {
    final sell = MockPrices.sellPrice(fiat);
    if (sell == null || (coin != 'USDT' && coin != 'USDC')) return null;
    final buy = MockPrices.buyPrice(fiat);
    final factor = coin == 'USDC' ? _usdcFactor : Decimal.one;
    final bid = sell * _criptoyaSpread * factor;
    final ask = (buy == null ? _vesAsk : buy * _criptoyaSpread) * factor;
    return (bid: bid, ask: ask);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);

    final segments = options.uri.pathSegments;
    final targets = segments.length >= 3
        ? targetsFor(
            segments[segments.length - 3].toUpperCase(),
            segments[segments.length - 2].toUpperCase(),
          )
        : null;
    if (targets == null) {
      return handler.reject(
        _badResponse(options, 404, const {'error': 'Invalid pair'}),
      );
    }

    switch (scenario) {
      case CriptoYaMockScenario.success:
        handler.resolve(_ok(options, _body(targets.bid, targets.ask)));
      case CriptoYaMockScenario.noOffers:
        handler.resolve(_ok(options, _body(Decimal.zero, Decimal.zero)));
      case CriptoYaMockScenario.rateLimited:
        handler.reject(_badResponse(options, 429, 'Too Many Requests'));
      case CriptoYaMockScenario.serverError:
        handler.reject(_badResponse(options, 500, 'Internal Server Error'));
      case CriptoYaMockScenario.timeout:
        handler.reject(
          DioException.receiveTimeout(
            timeout: options.receiveTimeout ?? Duration.zero,
            requestOptions: options,
          ),
        );
      case CriptoYaMockScenario.malformed:
        handler.resolve(_ok(options, '<html>Service unavailable</html>'));
    }
  }

  /// Como el API real, los precios son números JSON.
  static Map<String, Object?> _body(Decimal bid, Decimal ask) {
    num asJson(Decimal value) => num.parse(value.toString());
    return {
      for (final (index, exchange) in _exchanges.indexed)
        exchange: index < _spreads.length
            ? {
                'ask': asJson(ask * _spreads[index]),
                'totalAsk': asJson(ask * _spreads[index]),
                'bid': asJson(bid * _spreads[index]),
                'totalBid': asJson(bid * _spreads[index]),
                'time': 1794595489,
              }
            : {
                'ask': 0,
                'totalAsk': 0,
                'bid': 0,
                'totalBid': 0,
                'time': 1794595489,
              },
    };
  }

  static Response<Object?> _ok(RequestOptions options, Object? data) =>
      Response(requestOptions: options, statusCode: 200, data: data);

  static DioException _badResponse(
    RequestOptions options,
    int status,
    Object? data,
  ) => DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import 'fake_prices.dart';

/// Cómo responde [FakeOrderbookApi].
enum OrderbookScenario {
  success,

  /// `{"data": {}}`.
  noOffers,

  /// `{"error": {"code": "INVALID_REQUEST", …}}` con HTTP 200.
  invalidRequest,

  /// HTTP 502 del gateway.
  serverError,
  timeout,

  /// HTML en lugar de JSON.
  malformed,
}

/// API de órdenes falsa: responde como el documentado (API_RESEARCH.md §2),
/// sin red. HTTP 200 siempre, `data: {}` sin ofertas y `error` en el body.
///
/// Usa los precios de [FakePrices] (USDT→VES = 25.00, como el diseño),
/// límites de 5 a 500 USDT, `marketMakerOrderTime` de 10 min y ninguna
/// oferta para USDC (deshabilitado en El Dorado).
class FakeOrderbookApi extends Interceptor {
  FakeOrderbookApi({this.scenario = OrderbookScenario.success});

  final OrderbookScenario scenario;

  static const _required = [
    'type',
    'cryptoCurrencyId',
    'fiatCurrencyId',
    'amount',
    'amountCurrencyId',
  ];
  static final Decimal _minUsdt = Decimal.fromInt(5);
  static final Decimal _maxUsdt = Decimal.fromInt(500);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    switch (scenario) {
      case OrderbookScenario.serverError:
        return handler.reject(
          DioException.badResponse(
            statusCode: 502,
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 502),
          ),
        );
      case OrderbookScenario.timeout:
        return handler.reject(
          DioException.receiveTimeout(
            timeout: options.receiveTimeout ?? Duration.zero,
            requestOptions: options,
          ),
        );
      case OrderbookScenario.malformed:
        return handler.resolve(_ok(options, '<html>Bad gateway</html>'));
      case OrderbookScenario.invalidRequest:
        return handler.resolve(_ok(options, _error('Invalid request format')));
      case OrderbookScenario.noOffers:
        return handler.resolve(_ok(options, _noOffers));
      case OrderbookScenario.success:
        return handler.resolve(_ok(options, _respond(options.queryParameters)));
    }
  }

  static const _noOffers = {'data': <String, Object?>{}};

  static Map<String, Object?> _error(String reason) => {
    'error': {'code': 'INVALID_REQUEST', 'message': 'INVALID_REQUEST: $reason'},
  };

  static Map<String, Object?> _respond(Map<String, dynamic> query) {
    final missing = _required.where((key) => query[key] == null).toList();
    if (missing.isNotEmpty) return _error('missing ${missing.join(', ')}');

    final type = '${query['type']}';
    final crypto = '${query['cryptoCurrencyId']}';
    final fiat = '${query['fiatCurrencyId']}';
    final amount = Decimal.tryParse('${query['amount']}');
    final amountCurrency = '${query['amountCurrencyId']}';
    if (amount == null || (type != '0' && type != '1')) {
      return _error('invalid type or amount');
    }

    if (crypto != 'TATUM-TRON-USDT') return _noOffers; // USDC deshabilitado.
    final rate = type == '0'
        ? FakePrices.sellPrice(fiat)
        : FakePrices.buyPrice(fiat);
    if (rate == null) return _noOffers;

    final amountInUsdt = amountCurrency == crypto
        ? amount
        : (amount / rate).toDecimal(scaleOnInfinitePrecision: 8);
    if (amountInUsdt < _minUsdt || amountInUsdt > _maxUsdt) return _noOffers;

    return {
      'data': {'byPrice': _offer(type, crypto, fiat, rate)},
    };
  }

  static Map<String, Object?> _offer(
    String type,
    String crypto,
    String fiat,
    Decimal rate,
  ) => {
    'offerId': 'fake-offer',
    'offerType': int.parse(type),
    'cryptoCurrencyId': crypto,
    'fiatCurrencyId': fiat,
    'fiatToCryptoExchangeRate': rate.toString(),
    'limits': {
      'crypto': {'minLimit': '$_minUsdt', 'maxLimit': '$_maxUsdt'},
      'fiat': {
        'minLimit': '${_minUsdt * rate}',
        'maxLimit': '${_maxUsdt * rate}',
      },
    },
    'offerMakerStats': {'marketMakerOrderTime': 10, 'releaseTime': 1.5},
    'user_status': 'ONLINE',
  };

  static Response<Object?> _ok(RequestOptions options, Object? data) =>
      Response(requestOptions: options, statusCode: 200, data: data);
}

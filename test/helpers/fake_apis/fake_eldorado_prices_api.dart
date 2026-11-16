import 'package:dio/dio.dart';

import 'fake_prices.dart';

/// Cómo responde [FakeEldoradoPricesApi].
enum EldoradoPricesScenario {
  success,

  /// `{"SELL": {}, "BUY": {}}`: ningún par disponible.
  empty,

  /// HTTP 503.
  serverError,
  timeout,

  /// HTML en lugar de JSON.
  malformed,
}

/// API de precios de El Dorado falsa: responde `GET …/prices` con la forma
/// y la cobertura del API real, sin red. Cualquier otra ruta da 404.
class FakeEldoradoPricesApi extends Interceptor {
  FakeEldoradoPricesApi({this.scenario = EldoradoPricesScenario.success});

  final EldoradoPricesScenario scenario;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.uri.path.endsWith('/prices')) {
      return handler.reject(_badResponse(options, 404));
    }
    switch (scenario) {
      case EldoradoPricesScenario.success:
        handler.resolve(_ok(options, FakePrices.pricesJson()));
      case EldoradoPricesScenario.empty:
        handler.resolve(
          _ok(options, {
            'SELL': <String, Object?>{},
            'BUY': <String, Object?>{},
          }),
        );
      case EldoradoPricesScenario.serverError:
        handler.reject(_badResponse(options, 503));
      case EldoradoPricesScenario.timeout:
        handler.reject(
          DioException.receiveTimeout(
            timeout: options.receiveTimeout ?? Duration.zero,
            requestOptions: options,
          ),
        );
      case EldoradoPricesScenario.malformed:
        handler.resolve(_ok(options, '<html>Service unavailable</html>'));
    }
  }

  static Response<Object?> _ok(RequestOptions options, Object? data) =>
      Response(requestOptions: options, statusCode: 200, data: data);

  static DioException _badResponse(RequestOptions options, int status) =>
      DioException.badResponse(
        statusCode: status,
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: status,
          data: {'message': 'HTTP $status'},
        ),
      );
}

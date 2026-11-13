import 'package:coding_dorado/features/exchange/data/eldorado/mock/mock_prices.dart';
import 'package:dio/dio.dart';

enum EldoradoMockScenario {
  success,

  /// `{"SELL": {}, "BUY": {}}`: ningún par disponible.
  empty,

  /// HTTP 503.
  serverError,
  timeout,

  /// HTML en lugar de JSON.
  malformed
  ;

  static EldoradoMockScenario parse(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'empty' => empty,
        'server_error' => serverError,
        'timeout' => timeout,
        'malformed' => malformed,
        _ => success,
      };
}

/// Responde `GET …/prices` con la forma y la cobertura del API real, sin red.
class MockEldoradoPricesInterceptor extends Interceptor {
  MockEldoradoPricesInterceptor({
    this.scenario = EldoradoMockScenario.success,
    this.latency = Duration.zero,
  });

  final EldoradoMockScenario scenario;
  final Duration latency;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);

    if (!options.uri.path.endsWith('/prices')) {
      return handler.reject(_badResponse(options, 404));
    }
    switch (scenario) {
      case EldoradoMockScenario.success:
        handler.resolve(_ok(options, MockPrices.pricesJson()));
      case EldoradoMockScenario.empty:
        handler.resolve(
          _ok(options, {
            'SELL': <String, Object?>{},
            'BUY': <String, Object?>{},
          }),
        );
      case EldoradoMockScenario.serverError:
        handler.reject(_badResponse(options, 503));
      case EldoradoMockScenario.timeout:
        handler.reject(
          DioException.receiveTimeout(
            timeout: options.receiveTimeout ?? Duration.zero,
            requestOptions: options,
          ),
        );
      case EldoradoMockScenario.malformed:
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
          data: {'message': 'mock $status'},
        ),
      );
}

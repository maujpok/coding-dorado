import 'package:coding_dorado/features/exchange/data/eldorado/mock/mock_eldorado_prices_interceptor.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/mock/mock_prices.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/data_test_utils.dart';

void main() {
  Future<Response<Object?>> get(
    EldoradoMockScenario scenario, {
    String path = '/prices',
  }) => mockedDio(
    MockEldoradoPricesInterceptor(scenario: scenario),
  ).get<Object?>(path);

  test('parse reconoce los escenarios y cae en success', () {
    expect(
      EldoradoMockScenario.parse('server_error'),
      EldoradoMockScenario.serverError,
    );
    expect(EldoradoMockScenario.parse(' EMPTY '), EldoradoMockScenario.empty);
    expect(EldoradoMockScenario.parse('???'), EldoradoMockScenario.success);
  });

  test('success: misma forma y cobertura que el API real', () async {
    final response = await get(EldoradoMockScenario.success);
    final body = response.data! as Map<String, Object?>;
    final sell = body['SELL']! as Map<String, Object?>;
    final buy = body['BUY']! as Map<String, Object?>;

    expect(response.statusCode, 200);
    expect(sell.keys, containsAll(<String>['VES', 'COP', 'ARS', 'BOB']));
    expect(buy.keys, isNot(contains('VES')));
    expect(sell['VES'], {
      'limits': {
        'in': {'min': '5'},
        'out': {'min': '125'},
      },
      'price': '25',
    });
    expect(MockPrices.buyPrice('COP').toString(), '3366');
  });

  test('empty: SELL y BUY vacíos', () async {
    final response = await get(EldoradoMockScenario.empty);

    expect(response.data, {
      'SELL': <String, Object?>{},
      'BUY': <String, Object?>{},
    });
  });

  test('malformed: HTML con HTTP 200', () async {
    final response = await get(EldoradoMockScenario.malformed);

    expect(response.data, isA<String>());
  });

  test('server_error: HTTP 503', () async {
    await expectLater(
      get(EldoradoMockScenario.serverError),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          503,
        ),
      ),
    );
  });

  test('timeout: receiveTimeout', () async {
    await expectLater(
      get(EldoradoMockScenario.timeout),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );
  });

  test('otras rutas: HTTP 404', () async {
    await expectLater(
      get(EldoradoMockScenario.success, path: '/otra'),
      throwsA(isA<DioException>()),
    );
  });
}

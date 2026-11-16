import 'package:coding_dorado/core/cache/ttl_cache.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_model.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_prices_data_source.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/prices_response.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/data_test_utils.dart';
import '../../../../helpers/fake_apis/fake_eldorado_prices_api.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  const usdt = TestCurrencies.usdt;
  const usdc = TestCurrencies.usdc;
  const ves = TestCurrencies.ves;
  const cop = TestCurrencies.cop;

  late RequestCounter counter;
  late EldoradoPricesDataSource dataSource;

  setUp(() {
    counter = RequestCounter();
    dataSource = EldoradoPricesDataSource(
      fakeDio(FakeEldoradoPricesApi(), counter: counter),
    );
  });

  Future<ExchangeRateModel> fetch(ExchangePair pair, {String amount = '5'}) =>
      dataSource.fetchRate(pair: pair, amount: dec(amount));

  test('pide GET {base}/prices', () async {
    await fetch(ExchangePair(from: usdt, to: ves));

    expect(counter.requests.single.toString(), 'https://api.test/api/prices');
  });

  test('crypto → fiat usa SELL, con mínimo en USDT y tiempo fijo', () async {
    final model = await fetch(ExchangePair(from: usdt, to: ves));

    expect(model.rate, dec('25'));
    expect(model.minAmount, dec('5'));
    expect(model.estimatedTime, const Duration(minutes: 10));
    expect(model.sampleSize, isNull);
  });

  test('fiat → crypto usa BUY, con mínimo en fiat', () async {
    final model = await fetch(ExchangePair(from: cop, to: usdt));

    expect(model.rate, dec('3366'));
    expect(model.minAmount, dec('16830'));
  });

  test('USDC no se cotiza', () async {
    await expectLater(
      fetch(ExchangePair(from: usdc, to: ves)),
      throwsA(isA<UnsupportedPairException>()),
    );
    expect(counter.count, 0);
  });

  test('VES → USDT no se cotiza (VES no está en BUY)', () async {
    await expectLater(
      fetch(ExchangePair(from: ves, to: usdt)),
      throwsA(isA<UnsupportedPairException>()),
    );
  });

  group('caché', () {
    test('varios montos y pares dentro de 60 s → una sola petición', () async {
      await fetch(ExchangePair(from: usdt, to: ves));
      await fetch(
        ExchangePair(from: usdt, to: ves),
        amount: '50',
      );
      await fetch(
        ExchangePair(from: cop, to: usdt),
        amount: '20000',
      );
      await dataSource.availability();

      expect(counter.count, 1);
    });

    test('dos llamadas simultáneas → una petición', () async {
      await Future.wait([
        fetch(ExchangePair(from: usdt, to: ves)),
        fetch(
          ExchangePair(from: cop, to: usdt),
          amount: '20000',
        ),
      ]);

      expect(counter.count, 1);
    });

    test('al vencer el TTL se vuelve a pedir', () async {
      var now = DateTime(2026, 11, 13, 12);
      dataSource = EldoradoPricesDataSource(
        fakeDio(FakeEldoradoPricesApi(), counter: counter),
        cache: TtlCache<String, PricesResponse>(
          ttl: EldoradoPricesDataSource.cacheTtl,
          now: () => now,
        ),
      );

      await fetch(ExchangePair(from: usdt, to: ves));
      now = now.add(const Duration(seconds: 61));
      await fetch(ExchangePair(from: usdt, to: ves));

      expect(counter.count, 2);
    });

    test('forceRefresh vuelve a pedir', () async {
      await fetch(ExchangePair(from: usdt, to: ves));
      await dataSource.fetchRate(
        pair: ExchangePair(from: usdt, to: ves),
        amount: dec('5'),
        forceRefresh: true,
      );

      expect(counter.count, 2);
    });
  });

  test('availability refleja la cobertura: VES solo al vender', () async {
    final availability = await dataSource.availability();

    expect(availability.isAvailable(ExchangePair(from: usdt, to: ves)), isTrue);
    expect(
      availability.isAvailable(ExchangePair(from: ves, to: usdt)),
      isFalse,
    );
    expect(availability.isAvailable(ExchangePair(from: cop, to: usdt)), isTrue);
    expect(
      availability.isAvailable(ExchangePair(from: usdc, to: cop)),
      isFalse,
    );
  });

  test('propaga los errores HTTP como DioException', () async {
    dataSource = EldoradoPricesDataSource(
      fakeDio(
        FakeEldoradoPricesApi(
          scenario: EldoradoPricesScenario.serverError,
        ),
      ),
    );

    await expectLater(
      fetch(ExchangePair(from: usdt, to: ves)),
      throwsA(isA<DioException>()),
    );
  });
}

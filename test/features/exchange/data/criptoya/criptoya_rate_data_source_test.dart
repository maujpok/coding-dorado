import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/mock/mock_criptoya_interceptor.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/data_test_utils.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  const usdt = TestCurrencies.usdt;
  const usdc = TestCurrencies.usdc;
  const ves = TestCurrencies.ves;
  const cop = TestCurrencies.cop;

  late RequestCounter counter;

  CriptoYaRateDataSource dataSourceWith(Object? data) => CriptoYaRateDataSource(
    mockedDio(StaticResponseInterceptor(data), counter: counter),
  );

  CriptoYaRateDataSource mockDataSource([
    CriptoYaMockScenario scenario = CriptoYaMockScenario.success,
  ]) => CriptoYaRateDataSource(
    mockedDio(MockCriptoYaInterceptor(scenario: scenario), counter: counter),
  );

  setUp(() => counter = RequestCounter());

  test('pide /{coin}/{fiat}/1 en minúsculas', () async {
    await mockDataSource().fetchRate(
      pair: ExchangePair(from: usdc, to: cop),
      amount: dec('5'),
    );

    expect(counter.requests.single.path, '/api/usdc/cop/1');
  });

  test('vender usa totalBid y comprar totalAsk (mediana real)', () async {
    final dataSource = dataSourceWith(
      readJsonFixture('criptoya/usdt_ves_1.json'),
    );

    final sell = await dataSource.fetchRate(
      pair: ExchangePair(from: usdt, to: ves),
      amount: dec('5'),
    );
    final buy = await dataSource.fetchRate(
      pair: ExchangePair(from: ves, to: usdt),
      amount: dec('5000'),
    );

    expect(sell.rate, dec('1050'));
    expect(sell.sampleSize, 7);
    expect(buy.rate, dec('1069'));
    expect(sell.minAmount, isNull);
    expect(sell.estimatedTime, isNull);
  });

  test('sin ofertas → NoOffersException', () async {
    await expectLater(
      dataSourceWith(readJsonFixture('criptoya/all_zero.json')).fetchRate(
        pair: ExchangePair(from: usdt, to: ves),
        amount: dec('5'),
      ),
      throwsA(isA<NoOffersException>()),
    );
  });

  test('una petición por par dentro de los 30 s', () async {
    final dataSource = mockDataSource();
    final usdtVes = ExchangePair(from: usdt, to: ves);

    await dataSource.fetchRate(pair: usdtVes, amount: dec('5'));
    await dataSource.fetchRate(pair: usdtVes.swapped(), amount: dec('100'));
    await dataSource.fetchRate(pair: usdtVes, amount: dec('50'));
    await dataSource.fetchRate(
      pair: ExchangePair(from: usdt, to: cop),
      amount: dec('5'),
    );

    expect(counter.count, 2);
  });

  test('availability es desconocida', () async {
    expect(
      await mockDataSource().availability(),
      const PairAvailability.unknown(),
    );
  });

  group('mock', () {
    test('mediana = SELL de El Dorado × 1.01 al vender', () async {
      final rate = await mockDataSource().fetchRate(
        pair: ExchangePair(from: usdt, to: ves),
        amount: dec('5'),
      );

      expect(rate.rate, dec('25.25'));
      expect(rate.sampleSize, 3);
    });

    test('mediana = BUY de El Dorado × 1.01 al comprar', () async {
      final rate = await mockDataSource().fetchRate(
        pair: ExchangePair(from: cop, to: usdt),
        amount: dec('33660'),
      );

      expect(rate.rate, dec('3399.66'));
    });

    test('VES al comprar y USDC también cotizan', () async {
      final ves2usdt = await mockDataSource().fetchRate(
        pair: ExchangePair(from: ves, to: usdt),
        amount: dec('100'),
      );
      final usdc2ves = await mockDataSource().fetchRate(
        pair: ExchangePair(from: usdc, to: ves),
        amount: dec('5'),
      );

      expect(ves2usdt.rate, dec('25.75'));
      expect(usdc2ves.rate, dec('25.1995'));
    });

    test('parse reconoce los escenarios', () {
      expect(
        CriptoYaMockScenario.parse('rate_limited'),
        CriptoYaMockScenario.rateLimited,
      );
      expect(
        CriptoYaMockScenario.parse('no_offers'),
        CriptoYaMockScenario.noOffers,
      );
      expect(CriptoYaMockScenario.parse(''), CriptoYaMockScenario.success);
    });
  });

  group('CriptoYaExchangeRepository', () {
    final usdtToVes = ExchangePair(from: usdt, to: ves);

    Future<Result<ExchangeRate>> rateFor(CriptoYaMockScenario scenario) =>
        CriptoYaExchangeRepository(
          mockDataSource(scenario),
        ).getRate(pair: usdtToVes, amount: dec('5'));

    test('identifica al proveedor', () {
      expect(
        CriptoYaExchangeRepository(mockDataSource()).provider,
        RateProvider.criptoya,
      );
    });

    final expectations = <CriptoYaMockScenario, Failure>{
      CriptoYaMockScenario.noOffers: const NoOffersFailure(),
      CriptoYaMockScenario.rateLimited: const ServerFailure(429),
      CriptoYaMockScenario.serverError: const ServerFailure(500),
      CriptoYaMockScenario.timeout: const TimeoutFailure(),
      CriptoYaMockScenario.malformed: const ParsingFailure(),
    };
    for (final MapEntry(key: scenario, value: failure)
        in expectations.entries) {
      test('${scenario.name} → ${failure.runtimeType}', () async {
        expect(await rateFor(scenario), Err<ExchangeRate>(failure));
      });
    }

    test('par desconocido (404 Invalid pair) → PairUnavailableFailure', () {
      final repository = CriptoYaExchangeRepository(
        CriptoYaRateDataSource(mockedDio(MockCriptoYaInterceptor())),
      );
      // El mock solo conoce las fiat del catálogo.
      const unknownFiat = Currency(
        code: 'XYZ',
        name: 'Desconocida',
        symbol: 'X',
        type: CurrencyType.fiat,
      );
      final pair = ExchangePair(from: usdt, to: unknownFiat);

      expect(
        repository.getRate(pair: pair, amount: dec('5')),
        completion(const Err<ExchangeRate>(PairUnavailableFailure())),
      );
    });
  });
}

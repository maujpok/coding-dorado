import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/orderbook/orderbook_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/orderbook/recommendation_response.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../helpers/data_test_utils.dart';
import '../../../../helpers/fake_apis/fake_eldorado_prices_api.dart';
import '../../../../helpers/fake_apis/fake_orderbook_api.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_currencies.dart';

const endpoint =
    'https://orderbook.test/stage/orderbook/public/recommendations';

void main() {
  const usdt = CurrencyCatalog.usdt;
  const usdc = CurrencyCatalog.usdc;
  const ves = CurrencyCatalog.ves;
  const cop = CurrencyCatalog.cop;

  group('RecommendationResponse (forma documentada)', () {
    test('lee la tasa (string), los mínimos y el tiempo del maker', () {
      final offer = RecommendationResponse.parse(
        readJsonFixture('eldorado/recommendation_documented.json'),
      );

      expect(offer.fiatToCryptoExchangeRate, dec('3607.999'));
      expect(offer.cryptoMin, dec('1.51'));
      expect(offer.fiatMin, dec('7215.998'));
      expect(offer.marketMakerOrderTime, dec('4.49'));
    });

    test('data vacío → NoOffersException', () {
      expect(
        () => RecommendationResponse.parse(
          readJsonFixture('eldorado/recommendation_no_offers.json'),
        ),
        throwsA(isA<NoOffersException>()),
      );
    });

    test('error en el body (HTTP 200) → ApiErrorException con código', () {
      expect(
        () => RecommendationResponse.parse(
          readJsonFixture('eldorado/recommendation_invalid_request.json'),
        ),
        throwsA(
          isA<ApiErrorException>().having(
            (e) => e.code,
            'code',
            'INVALID_REQUEST',
          ),
        ),
      );
    });

    test('tasa numérica y campos opcionales ausentes', () {
      final offer = RecommendationResponse.parse(const {
        'data': {
          'byPrice': {'fiatToCryptoExchangeRate': 25},
        },
      });

      expect(offer.fiatToCryptoExchangeRate, dec('25'));
      expect(offer.marketMakerOrderTime, isNull);
      expect(offer.cryptoMin, isNull);
    });

    test('formas inválidas → ParsingException', () {
      for (final json in <Object?>[
        '<html></html>',
        const {'data': 'x'},
        const {
          'data': {
            'byPrice': {'fiatToCryptoExchangeRate': 'n/a'},
          },
        },
      ]) {
        expect(
          () => RecommendationResponse.parse(json),
          throwsA(isA<ParsingException>()),
          reason: '$json',
        );
      }
    });
  });

  group('OrderbookRateDataSource', () {
    test('arma los query params en ambas direcciones', () {
      expect(
        OrderbookRateDataSource.queryFor(
          ExchangePair(from: usdt, to: ves),
          dec('5'),
        ),
        {
          'type': 0,
          'cryptoCurrencyId': 'TATUM-TRON-USDT',
          'fiatCurrencyId': 'VES',
          'amount': '5',
          'amountCurrencyId': 'TATUM-TRON-USDT',
        },
      );
      expect(
        OrderbookRateDataSource.queryFor(
          ExchangePair(from: cop, to: usdc),
          dec('20000'),
        ),
        {
          'type': 1,
          'cryptoCurrencyId': 'TATUM-MATIC-USDC',
          'fiatCurrencyId': 'COP',
          'amount': '20000',
          'amountCurrencyId': 'COP',
        },
      );
    });

    test(
      'tiempo estimado redondeado hacia arriba y mínimo del lado TENGO',
      () async {
        final dataSource = OrderbookRateDataSource(
          fakeDio(
            StaticResponseInterceptor(
              readJsonFixture('eldorado/recommendation_documented.json'),
            ),
            baseUrl: '',
          ),
          endpoint: endpoint,
        );

        final sell = await dataSource.fetchRate(
          pair: ExchangePair(from: usdt, to: cop),
          amount: dec('10'),
        );
        final buy = await dataSource.fetchRate(
          pair: ExchangePair(from: cop, to: usdt),
          amount: dec('50000'),
        );

        expect(sell.rate, dec('3607.999'));
        expect(sell.estimatedTime, const Duration(minutes: 5));
        expect(sell.minAmount, dec('1.51'));
        expect(buy.minAmount, dec('7215.998'));
      },
    );

    test('la caché distingue montos (la tasa depende del monto)', () async {
      final counter = RequestCounter();
      final dataSource = OrderbookRateDataSource(
        fakeDio(FakeOrderbookApi(), counter: counter, baseUrl: ''),
        endpoint: endpoint,
      );
      final pair = ExchangePair(from: usdt, to: ves);

      await dataSource.fetchRate(pair: pair, amount: dec('5'));
      await dataSource.fetchRate(pair: pair, amount: dec('5'));
      await dataSource.fetchRate(pair: pair, amount: dec('6'));

      expect(counter.count, 2);
    });
  });

  group('API de órdenes falsa vía repositorio', () {
    Future<Result<ExchangeRate>> rateWith(
      OrderbookScenario scenario, {
      required ExchangePair pair,
      String amount = '5',
    }) => EldoradoExchangeRepository(
      OrderbookRateDataSource(
        fakeDio(FakeOrderbookApi(scenario: scenario), baseUrl: ''),
        endpoint: endpoint,
      ),
    ).getRate(pair: pair, amount: dec(amount));

    test('success: precio del diseño y 10 min', () async {
      final result = await rateWith(
        OrderbookScenario.success,
        pair: ExchangePair(from: usdt, to: ves),
      );

      expect(result.valueOrNull?.fiatPerCrypto, dec('25'));
      expect(result.valueOrNull?.estimatedTime, const Duration(minutes: 10));
    });

    test('USDC y montos fuera de límites → sin ofertas', () async {
      final usdcResult = await rateWith(
        OrderbookScenario.success,
        pair: ExchangePair(from: usdc, to: ves),
      );
      final tooBig = await rateWith(
        OrderbookScenario.success,
        pair: ExchangePair(from: usdt, to: ves),
        amount: '600',
      );

      expect(usdcResult.failureOrNull, const NoOffersFailure());
      expect(tooBig.failureOrNull, const NoOffersFailure());
    });

    final expectations = <OrderbookScenario, Failure>{
      OrderbookScenario.noOffers: const NoOffersFailure(),
      OrderbookScenario.invalidRequest: const InvalidRequestFailure(
        'INVALID_REQUEST',
      ),
      OrderbookScenario.serverError: const ServerFailure(502),
      OrderbookScenario.timeout: const TimeoutFailure(),
      OrderbookScenario.malformed: const ParsingFailure(),
    };
    for (final MapEntry(key: scenario, value: failure)
        in expectations.entries) {
      test('${scenario.name} → ${failure.runtimeType}', () async {
        final result = await rateWith(
          scenario,
          pair: ExchangePair(from: usdt, to: ves),
        );

        expect(result, Err<ExchangeRate>(failure));
      });
    }

    test('parámetros faltantes → error en el body', () async {
      final response = await fakeDio(
        FakeOrderbookApi(),
        baseUrl: '',
      ).get<Object?>(endpoint, queryParameters: {'type': 0});

      expect(
        () => RecommendationResponse.parse(response.data),
        throwsA(isA<ApiErrorException>()),
      );
    });
  });

  group('ELDORADO_SOURCE=orderbook', () {
    const orderbookConfig = AppConfig(
      eldoradoApiUrl: testEldoradoApiUrl,
      criptoyaApiUrl: testCriptoyaApiUrl,
      eldoradoSource: EldoradoSource.orderbook,
      orderbookApiUrl: endpoint,
    );
    final usdtToVes = ExchangePair(from: usdt, to: ves);

    test('con API_URL, la pestaña El Dorado usa el API de órdenes', () async {
      final getQuote = fakeApiDependencies(
        config: orderbookConfig,
      ).getExchangeQuote(RateProvider.eldorado);

      final quote = await getQuote(usdtToVes, dec('5'));
      // /api/prices no tiene máximo; el API de órdenes sí (500 USDT).
      final tooBig = await getQuote(usdtToVes, dec('600'));

      expect(quote.valueOrNull?.receiveAmount, dec('125'));
      expect(tooBig.failureOrNull, const NoOffersFailure());
    });

    test('sin API_URL vuelve a /api/prices', () async {
      final getIt = GetIt.asNewInstance();
      configureDependencies(
        getIt,
        // Sin orderbookApiUrl (API_URL vacía).
        const AppConfig(
          eldoradoApiUrl: testEldoradoApiUrl,
          criptoyaApiUrl: testCriptoyaApiUrl,
          eldoradoSource: EldoradoSource.orderbook,
        ),
        // Solo responde GET …/prices; cualquier otra ruta da 404.
        httpInterceptors: {
          RateProvider.eldorado: [FakeEldoradoPricesApi()],
        },
      );

      final quote = await getIt.getExchangeQuote(RateProvider.eldorado)(
        usdtToVes,
        dec('600'),
      );

      expect(quote.valueOrNull?.receiveAmount, dec('15000'));
    });
  });
}

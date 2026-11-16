import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/fake_apis/fake_criptoya_api.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_currencies.dart';

void main() {
  late GetIt getIt;

  setUp(() => getIt = fakeApiDependencies());

  test('registra un repositorio y un caso de uso por proveedor', () {
    for (final provider in RateProvider.values) {
      expect(getIt.exchangeRepository(provider).provider, provider);
      expect(getIt.getExchangeQuote(provider).provider, provider);
    }
    expect(getIt.allQuoteUseCases().keys, RateProvider.values);
  });

  test('sin interceptores arma todo sin hacer peticiones', () {
    final real = GetIt.asNewInstance();
    configureDependencies(real, testAppConfig);

    expect(real<AppConfig>(), testAppConfig);
    expect(real.allQuoteUseCases().keys, RateProvider.values);
  });

  group('integración de datos con las APIs falsas', () {
    test('5 USDT → VES: El Dorado 125.00 y CriptoYa 126.25', () async {
      final pair = ExchangePair(
        from: CurrencyCatalog.usdt,
        to: CurrencyCatalog.ves,
      );

      final eldorado = await getIt.getExchangeQuote(RateProvider.eldorado)(
        pair,
        dec('5'),
      );
      final criptoya = await getIt.getExchangeQuote(RateProvider.criptoya)(
        pair,
        dec('5'),
      );

      expect(eldorado.valueOrNull?.receiveAmount, dec('125'));
      expect(criptoya.valueOrNull?.receiveAmount, dec('126.25'));
    });

    test('VES → USDT: El Dorado no lo cotiza, CriptoYa sí', () async {
      final pair = ExchangePair(
        from: CurrencyCatalog.ves,
        to: CurrencyCatalog.usdt,
      );

      final eldorado = await getIt.getExchangeQuote(RateProvider.eldorado)(
        pair,
        dec('100'),
      );
      final criptoya = await getIt.getExchangeQuote(RateProvider.criptoya)(
        pair,
        dec('100'),
      );

      expect(eldorado.failureOrNull, const PairUnavailableFailure());
      expect(criptoya.isOk, isTrue);
    });

    test('4 USDT → COP en El Dorado: bajo el mínimo', () async {
      final result = await getIt.getExchangeQuote(RateProvider.eldorado)(
        ExchangePair(from: CurrencyCatalog.usdt, to: CurrencyCatalog.cop),
        dec('4'),
      );

      expect(result.failureOrNull, BelowMinimumFailure(dec('5')));
    });

    test('httpInterceptors se aplican por proveedor', () async {
      final other = fakeApiDependencies(criptoya: CriptoYaScenario.rateLimited);
      final pair = ExchangePair(
        from: CurrencyCatalog.usdt,
        to: CurrencyCatalog.ves,
      );

      final eldorado = await other.getExchangeQuote(RateProvider.eldorado)(
        pair,
        dec('5'),
      );
      final criptoya = await other.getExchangeQuote(RateProvider.criptoya)(
        pair,
        dec('5'),
      );

      expect(eldorado.isOk, isTrue);
      expect(criptoya.failureOrNull, const ServerFailure(429));
    });
  });
}

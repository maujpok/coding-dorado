import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/data/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/test_currencies.dart';

AppConfig mockConfig({
  String eldorado = 'success',
  String criptoya = 'success',
}) => AppConfig(
  eldoradoApiUrl: AppConfig.defaultEldoradoApiUrl,
  criptoyaApiUrl: AppConfig.defaultCriptoyaApiUrl,
  useMock: true,
  mockScenarioEldorado: eldorado,
  mockScenarioCriptoya: criptoya,
  mockLatency: Duration.zero,
  eldoradoSource: EldoradoSource.prices,
  orderbookApiUrl: '',
);

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance();
    configureDependencies(getIt, mockConfig());
  });

  test('registra un repositorio y un caso de uso por proveedor', () {
    for (final provider in RateProvider.values) {
      expect(getIt.exchangeRepository(provider).provider, provider);
      expect(getIt.getExchangeQuote(provider).provider, provider);
    }
    expect(getIt.allQuoteUseCases().keys, RateProvider.values);
  });

  group('integración de datos en modo mock', () {
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

    test('los escenarios del mock se configuran por proveedor', () async {
      final other = GetIt.asNewInstance();
      configureDependencies(other, mockConfig(criptoya: 'rate_limited'));
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

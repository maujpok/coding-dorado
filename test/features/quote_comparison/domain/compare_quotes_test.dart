import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../helpers/fake_exchange_repository.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_currencies.dart';

void main() {
  const usdt = CurrencyCatalog.usdt;
  const ves = CurrencyCatalog.ves;
  const cop = CurrencyCatalog.cop;

  group('con los datos del mock (pila real)', () {
    late CompareQuotes compare;

    setUp(() {
      final getIt = GetIt.asNewInstance();
      configureDependencies(getIt, mockAppConfig());
      compare = getIt<CompareQuotes>();
    });

    test('5 USDT → VES: gana CriptoYa por 1.25 VES (+1.00 %)', () async {
      final result = await compare(ExchangePair(from: usdt, to: ves), dec('5'));

      expect(
        result.results[RateProvider.eldorado]?.valueOrNull?.receiveAmount,
        dec('125'),
      );
      expect(
        result.results[RateProvider.criptoya]?.valueOrNull?.receiveAmount,
        dec('126.25'),
      );
      expect(result.best, RateProvider.criptoya);
      expect(result.difference, dec('1.25'));
      expect(result.differencePercent, dec('1'));
      expect(result.isTie, isFalse);
    });

    test('33 660 COP → USDT: gana El Dorado', () async {
      final result = await compare(
        ExchangePair(from: cop, to: usdt),
        dec('33660'),
      );

      expect(
        result.results[RateProvider.eldorado]?.valueOrNull?.receiveAmount,
        dec('10'),
      );
      expect(result.best, RateProvider.eldorado);
      expect(result.difference! > dec('0.09'), isTrue);
    });

    test('VES → USDT: El Dorado no disponible, gana CriptoYa', () async {
      final result = await compare(
        ExchangePair(from: ves, to: usdt),
        dec('100'),
      );

      expect(
        result.results[RateProvider.eldorado],
        const Err<ExchangeQuote>(PairUnavailableFailure()),
      );
      expect(result.best, RateProvider.criptoya);
      expect(result.difference, isNull);
      expect(result.quotes, hasLength(1));
    });

    test('los resultados siguen el orden de las pestañas', () async {
      final result = await compare(ExchangePair(from: usdt, to: ves), dec('5'));

      expect(result.results.keys, RateProvider.values);
    });
  });

  group('con repositorios programables', () {
    CompareQuotes compareWith(
      RateHandler eldorado,
      RateHandler criptoya,
    ) => CompareQuotes({
      RateProvider.eldorado: GetExchangeQuote(
        FakeExchangeRepository(onGetRate: eldorado),
      ),
      RateProvider.criptoya: GetExchangeQuote(
        FakeExchangeRepository(
          provider: RateProvider.criptoya,
          onGetRate: criptoya,
        ),
      ),
    });

    Future<Result<ExchangeRate>> rate25(_, _) async =>
        Ok(ExchangeRate(fiatPerCrypto: dec('25')));
    Future<Result<ExchangeRate>> offline(_, _) async =>
        const Err(NetworkFailure());

    test('ambos fallan: sin mejor opción y con ambos errores', () async {
      final result = await compareWith(offline, offline)(
        ExchangePair(from: usdt, to: ves),
        dec('5'),
      );

      expect(result.best, isNull);
      expect(result.difference, isNull);
      expect(result.quotes, isEmpty);
      expect(
        result.results.values,
        everyElement(const Err<ExchangeQuote>(NetworkFailure())),
      );
    });

    test('tasas iguales: empate, sin mejor opción', () async {
      final result = await compareWith(rate25, rate25)(
        ExchangePair(from: usdt, to: ves),
        dec('5'),
      );

      expect(result.best, isNull);
      expect(result.difference, dec('0'));
      expect(result.isTie, isTrue);
    });

    test('pasa forceRefresh a todos los proveedores', () async {
      final eldorado = FakeExchangeRepository();
      final criptoya = FakeExchangeRepository(provider: RateProvider.criptoya);
      final compare = CompareQuotes({
        RateProvider.eldorado: GetExchangeQuote(eldorado),
        RateProvider.criptoya: GetExchangeQuote(criptoya),
      });

      await compare(
        ExchangePair(from: usdt, to: ves),
        dec('5'),
        forceRefresh: true,
      );

      expect(eldorado.calls.single.forceRefresh, isTrue);
      expect(criptoya.calls.single.forceRefresh, isTrue);
    });
  });
}

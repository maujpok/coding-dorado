import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_exchange_repository.dart';
import '../../../../helpers/test_currencies.dart';

const Currency usdt = CurrencyCatalog.usdt;
const Currency usdc = CurrencyCatalog.usdc;
const Currency ves = CurrencyCatalog.ves;
const Currency cop = CurrencyCatalog.cop;

/// El Dorado simplificado: tasa 25 (USDT→VES) o 3366 (COP↔USDT), mínimo
/// 5 USDT, sin VES al comprar ni USDC.
Future<Result<ExchangeRate>> eldoradoLike(
  ExchangePair pair,
  _,
) async {
  if (pair.crypto == usdc || pair.from == ves) {
    return const Err(PairUnavailableFailure());
  }
  final rate = pair.fiat == cop ? dec('3366') : dec('25');
  final min = pair.direction == ExchangeDirection.cryptoToFiat
      ? dec('5')
      : dec('5') * rate;
  return Ok(ExchangeRate(fiatPerCrypto: rate, minAmount: min));
}

TypeMatcher<ExchangeState> stateWhere({
  ExchangePair? pair,
  Object? quote,
  String? amountText,
}) {
  var matcher = isA<ExchangeState>();
  if (pair != null) matcher = matcher.having((s) => s.pair, 'pair', pair);
  if (quote != null) matcher = matcher.having((s) => s.quote, 'quote', quote);
  if (amountText != null) {
    matcher = matcher.having((s) => s.amountText, 'amountText', amountText);
  }
  return matcher;
}

TypeMatcher<QuoteLoaded> loadedWith(String receive) => isA<QuoteLoaded>()
    .having((q) => q.quote.receiveAmount, 'receiveAmount', dec(receive));

void main() {
  late FakeExchangeRepository repository;

  ExchangeBloc buildBloc({Duration debounce = Duration.zero}) => ExchangeBloc(
    getQuote: GetExchangeQuote(repository),
    repository: repository,
    quoteDebounce: debounce,
  );

  setUp(() {
    repository = FakeExchangeRepository(onGetRate: eldoradoLike);
  });

  test('estado inicial: USDT → BOB, sin monto, QuoteIdle', () {
    final bloc = buildBloc();

    expect(bloc.state.pair, ExchangePair(from: usdt, to: CurrencyCatalog.bob));
    expect(bloc.state.amount, isNull);
    expect(bloc.state.quote, const QuoteIdle());
    expect(bloc.state.canSubmit, isFalse);
  });

  blocTest<ExchangeBloc, ExchangeState>(
    'ExchangeStarted carga la disponibilidad',
    setUp: () => repository.availability = PairAvailability.only({
      PairAvailability.keyOf(ExchangePair(from: usdt, to: ves)),
    }),
    build: buildBloc,
    act: (bloc) => bloc.add(const ExchangeStarted()),
    expect: () => [
      isA<ExchangeState>().having(
        (s) => s.availability.isAvailable(ExchangePair(from: ves, to: usdt)),
        'VES→USDT disponible',
        isFalse,
      ),
    ],
  );

  blocTest<ExchangeBloc, ExchangeState>(
    '5 USDT → VES: Loading y luego Loaded con 125',
    build: buildBloc,
    act: (bloc) => bloc.add(const ExchangeAmountChanged('5')),
    expect: () => [
      stateWhere(amountText: '5', quote: const QuoteIdle()),
      stateWhere(quote: const QuoteLoading()),
      stateWhere(quote: loadedWith('125')),
    ],
    verify: (bloc) => expect(bloc.state.canSubmit, isTrue),
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'varios AmountChanged seguidos producen una sola cotización',
    build: () => buildBloc(debounce: const Duration(milliseconds: 30)),
    act: (bloc) => bloc
      ..add(const ExchangeAmountChanged('1'))
      ..add(const ExchangeAmountChanged('10'))
      ..add(const ExchangeAmountChanged('100')),
    wait: const Duration(milliseconds: 120),
    verify: (bloc) {
      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.amount, dec('100'));
      expect(bloc.state.quote, loadedWith('2500'));
    },
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'una respuesta obsoleta no se emite',
    build: buildBloc,
    setUp: () {
      final slow = Completer<Result<ExchangeRate>>();
      repository.onGetRate = (pair, amount) {
        if (pair.fiat == ves) {
          // Termina después de que llega la segunda cotización.
          Future<void>.delayed(
            const Duration(milliseconds: 40),
            () => slow.complete(Ok(ExchangeRate(fiatPerCrypto: dec('25')))),
          );
          return slow.future;
        }
        return eldoradoLike(pair, amount);
      };
    },
    act: (bloc) async {
      bloc.add(const ExchangeAmountChanged('5'));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      bloc.add(const ExchangeToCurrencySelected(cop));
    },
    wait: const Duration(milliseconds: 80),
    verify: (bloc) {
      expect(bloc.state.pair, ExchangePair(from: usdt, to: cop));
      expect(bloc.state.quote, loadedWith('16830'));
    },
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'swap invierte el par, conserva el monto y recotiza (VES→USDT no está)',
    build: buildBloc,
    seed: () => ExchangeState(
      pair: ExchangePair(from: usdt, to: ves),
      amountText: '5',
      amount: dec('5'),
    ),
    act: (bloc) => bloc.add(const ExchangeCurrenciesSwapped()),
    expect: () => [
      stateWhere(
        pair: ExchangePair(from: ves, to: usdt),
      ),
      stateWhere(quote: const QuoteLoading()),
      stateWhere(quote: const QuoteFailed(PairUnavailableFailure())),
    ],
    verify: (bloc) => expect(bloc.state.amount, dec('5')),
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'TENGO y QUIERO actualizan su lado; otro tipo de moneda se ignora',
    build: buildBloc,
    act: (bloc) => bloc
      ..add(const ExchangeToCurrencySelected(cop))
      ..add(const ExchangeFromCurrencySelected(usdc))
      ..add(const ExchangeFromCurrencySelected(ves)),
    verify: (bloc) {
      expect(bloc.state.pair, ExchangePair(from: usdc, to: cop));
      expect(repository.calls, isEmpty, reason: 'sin monto no se cotiza');
    },
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'monto bajo el mínimo → QuoteFailed(BelowMinimumFailure)',
    build: buildBloc,
    act: (bloc) => bloc.add(const ExchangeAmountChanged('4')),
    skip: 2,
    expect: () => [
      stateWhere(quote: QuoteFailed(BelowMinimumFailure(dec('5')))),
    ],
    verify: (bloc) => expect(bloc.state.canSubmit, isFalse),
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'ExchangePrefilled reemplaza par y monto y cotiza',
    build: buildBloc,
    act: (bloc) => bloc.add(
      ExchangePrefilled(
        pair: ExchangePair(from: cop, to: usdt),
        amount: dec('33660'),
      ),
    ),
    expect: () => [
      stateWhere(
        pair: ExchangePair(from: cop, to: usdt),
        amountText: '33660',
      ),
      stateWhere(quote: const QuoteLoading()),
      stateWhere(quote: loadedWith('10')),
    ],
  );

  blocTest<ExchangeBloc, ExchangeState>(
    'error → QuoteFailed; reintento → Loading → Loaded, ignorando la caché',
    build: buildBloc,
    setUp: () {
      var attempt = 0;
      repository.onGetRate = (pair, amount) async {
        attempt++;
        if (attempt == 1) return const Err(NetworkFailure());
        return eldoradoLike(pair, amount);
      };
    },
    act: (bloc) async {
      bloc.add(const ExchangeAmountChanged('5'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ExchangeRatesRefreshed());
    },
    expect: () => [
      stateWhere(amountText: '5'),
      stateWhere(quote: const QuoteLoading()),
      stateWhere(quote: const QuoteFailed(NetworkFailure())),
      stateWhere(quote: const QuoteLoading()),
      stateWhere(quote: loadedWith('125')),
    ],
    verify: (_) => expect(repository.calls.last.forceRefresh, isTrue),
  );

  for (final input in ['', '0', 'abc', '.']) {
    blocTest<ExchangeBloc, ExchangeState>(
      'monto "$input" → QuoteIdle y no se cotiza',
      build: buildBloc,
      seed: () => ExchangeState(
        pair: ExchangePair(from: usdt, to: ves),
        amountText: '5',
        amount: dec('5'),
      ),
      act: (bloc) => bloc.add(ExchangeAmountChanged(input)),
      verify: (bloc) {
        expect(bloc.state.amount, isNull);
        expect(bloc.state.quote, const QuoteIdle());
        expect(repository.calls, isEmpty);
      },
    );
  }

  final usdtToCop = PairAvailability.only({
    PairAvailability.keyOf(ExchangePair(from: usdt, to: cop)),
  });
  blocTest<ExchangeBloc, ExchangeState>(
    'reiniciar vuelve al par inicial sin monto y conserva la disponibilidad',
    build: buildBloc,
    seed: () => ExchangeState(
      pair: ExchangePair(from: usdt, to: cop),
      amountText: '5',
      amount: dec('5'),
      availability: usdtToCop,
    ),
    act: (bloc) => bloc.add(const ExchangeReset()),
    expect: () => [
      ExchangeState(pair: ExchangeBloc.defaultPair(), availability: usdtToCop),
    ],
    verify: (_) => expect(repository.calls, isEmpty),
  );

  test('reiniciar descarta una cotización en curso', () async {
    final pending = Completer<Result<ExchangeRate>>();
    repository.onGetRate = (_, _) => pending.future;
    final bloc = buildBloc()..add(const ExchangeAmountChanged('5'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote, isA<QuoteLoading>());

    bloc.add(const ExchangeReset());
    await Future<void>.delayed(Duration.zero);
    pending.complete(Ok(ExchangeRate(fiatPerCrypto: dec('25'))));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.amount, isNull);
    expect(bloc.state.quote, const QuoteIdle());
    await bloc.close();
  });

  blocTest<ExchangeBloc, ExchangeState>(
    'al volver a la app recotiza sin forzar la caché',
    build: buildBloc,
    seed: () => ExchangeState(
      pair: ExchangePair(from: usdt, to: ves),
      amountText: '5',
      amount: dec('5'),
    ),
    act: (bloc) => bloc.add(const ExchangeAppResumed()),
    verify: (_) {
      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.forceRefresh, isFalse);
    },
  );

  test('currentQuote ignora cotizaciones de otro par o monto', () async {
    final bloc = buildBloc()..add(const ExchangeAmountChanged('5'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.currentQuote, isNotNull);

    final stale = bloc.state.copyWith(amount: () => dec('6'));
    expect(stale.currentQuote, isNull);
    expect(stale.canSubmit, isFalse);
    await bloc.close();
  });
}

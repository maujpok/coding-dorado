import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_exchange_repository.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  const usdt = TestCurrencies.usdt;
  const ves = TestCurrencies.ves;
  const cop = TestCurrencies.cop;

  late FakeExchangeRepository repository;
  late GetExchangeQuote getQuote;

  void rateIs(ExchangeRate rate) {
    repository.onGetRate = (_, _) async => Ok(rate);
  }

  setUp(() {
    repository = FakeExchangeRepository(provider: RateProvider.criptoya);
    getQuote = GetExchangeQuote(repository);
  });

  test('5 USDT → VES con tasa 25 = 125 VES', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('25')));

    final result = await getQuote(ExchangePair(from: usdt, to: ves), dec('5'));

    final quote = (result as Ok<ExchangeQuote>).value;
    expect(quote.receiveAmount, dec('125'));
    expect(quote.provider, RateProvider.criptoya);
    expect(quote.amount, dec('5'));
  });

  test('125 COP → USDT con tasa 25 = 5 USDT', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('25')));

    final result = await getQuote(
      ExchangePair(from: cop, to: usdt),
      dec('125'),
    );

    expect(result.valueOrNull?.receiveAmount, dec('5'));
  });

  test('100 COP → USDT con tasa 3 = 33.33 (sin error de flotante)', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('3')));

    final result = await getQuote(
      ExchangePair(from: cop, to: usdt),
      dec('100'),
    );

    final receive = result.valueOrNull!.receiveAmount;
    expect(receive, dec('33.33333333'));
    expect(AmountFormatter.format(receive, truncate: true), '33.33');
  });

  test('4 USDT con mínimo 5 → BelowMinimumFailure(5)', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('25'), minAmount: dec('5')));

    final result = await getQuote(ExchangePair(from: usdt, to: ves), dec('4'));

    expect(result, Err<ExchangeQuote>(BelowMinimumFailure(dec('5'))));
  });

  test('el mínimo exacto es válido', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('25'), minAmount: dec('5')));

    final result = await getQuote(ExchangePair(from: usdt, to: ves), dec('5'));

    expect(result.isOk, isTrue);
  });

  test('sin mínimo no se valida', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('25')));

    final result = await getQuote(
      ExchangePair(from: usdt, to: ves),
      dec('0.01'),
    );

    expect(result.valueOrNull?.receiveAmount, dec('0.25'));
  });

  test('tasa 0 → InvalidRateFailure', () async {
    rateIs(ExchangeRate(fiatPerCrypto: dec('0')));

    final result = await getQuote(ExchangePair(from: usdt, to: ves), dec('5'));

    expect(result, const Err<ExchangeQuote>(InvalidRateFailure()));
  });

  test('propaga el Failure del repositorio', () async {
    repository.onGetRate = (_, _) async => const Err(PairUnavailableFailure());

    final result = await getQuote(ExchangePair(from: ves, to: usdt), dec('5'));

    expect(result, const Err<ExchangeQuote>(PairUnavailableFailure()));
  });

  test('pasa par, monto y forceRefresh al repositorio', () async {
    final pair = ExchangePair(from: usdt, to: ves);

    await getQuote(pair, dec('7'), forceRefresh: true);

    expect(repository.calls.single.pair, pair);
    expect(repository.calls.single.amount, dec('7'));
    expect(repository.calls.single.forceRefresh, isTrue);
  });
}

import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_currencies.dart';

void main() {
  const usdt = TestCurrencies.usdt;
  const usdc = TestCurrencies.usdc;
  const ves = TestCurrencies.ves;
  const cop = TestCurrencies.cop;

  group('ExchangePair', () {
    test('crypto → fiat', () {
      final pair = ExchangePair(from: usdt, to: ves);

      expect(pair.direction, ExchangeDirection.cryptoToFiat);
      expect(pair.crypto, usdt);
      expect(pair.fiat, ves);
    });

    test('fiat → crypto', () {
      final pair = ExchangePair(from: cop, to: usdc);

      expect(pair.direction, ExchangeDirection.fiatToCrypto);
      expect(pair.crypto, usdc);
      expect(pair.fiat, cop);
    });

    test('fiat ↔ fiat o crypto ↔ crypto lanzan ArgumentError', () {
      expect(() => ExchangePair(from: ves, to: cop), throwsArgumentError);
      expect(() => ExchangePair(from: usdt, to: usdc), throwsArgumentError);
    });

    test('swapped invierte los lados y la dirección', () {
      final swapped = ExchangePair(from: usdt, to: ves).swapped();

      expect(swapped, ExchangePair(from: ves, to: usdt));
      expect(swapped.direction, ExchangeDirection.fiatToCrypto);
    });

    test('withFrom y withTo reemplazan un lado', () {
      final pair = ExchangePair(from: usdt, to: ves);

      expect(pair.withFrom(usdc), ExchangePair(from: usdc, to: ves));
      expect(pair.withTo(cop), ExchangePair(from: usdt, to: cop));
      expect(() => pair.withTo(usdc), throwsArgumentError);
    });
  });

  group('PairAvailability', () {
    test('unknown habilita todos los pares', () {
      const availability = PairAvailability.unknown();

      expect(availability.isKnown, isFalse);
      expect(
        availability.isAvailable(ExchangePair(from: ves, to: usdc)),
        isTrue,
      );
    });

    test('only habilita solo los pares listados, por dirección', () {
      final availability = PairAvailability.only({
        PairAvailability.keyOf(ExchangePair(from: usdt, to: ves)),
      });

      expect(availability.isKnown, isTrue);
      expect(
        availability.isAvailable(ExchangePair(from: usdt, to: ves)),
        isTrue,
      );
      expect(
        availability.isAvailable(ExchangePair(from: ves, to: usdt)),
        isFalse,
      );
      expect(
        availability.isAvailable(ExchangePair(from: usdc, to: ves)),
        isFalse,
      );
    });
  });
}

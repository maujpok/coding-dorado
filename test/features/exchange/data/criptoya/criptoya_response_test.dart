import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_response.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/data_test_utils.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  group('median', () {
    test('cantidad impar: el valor central', () {
      expect(median([dec('3'), dec('1'), dec('2')]), dec('2'));
    });

    test('cantidad par: promedio de los centrales', () {
      expect(median([dec('4'), dec('1'), dec('3'), dec('2')]), dec('2.5'));
    });

    test('un solo valor', () {
      expect(median([dec('11.85')]), dec('11.85'));
    });

    test('lista vacía lanza ArgumentError', () {
      expect(() => median([]), throwsArgumentError);
    });
  });

  group('CriptoYaResponse con respuestas reales', () {
    test('USDT/VES: mediana por dirección, libro invertido incluido', () {
      final response = CriptoYaResponse.fromJson(
        readJsonFixture('criptoya/usdt_ves_1.json'),
      );
      final bids = response.pricesFor(ExchangeDirection.cryptoToFiat);
      final asks = response.pricesFor(ExchangeDirection.fiatToCrypto);

      // binancep2p tiene bid > ask; igual entra en la mediana.
      expect(bids, hasLength(7));
      expect(median(bids), dec('1050'));
      expect(median(asks), dec('1069'));
    });

    test('USDC/BOB: los exchanges en 0 se descartan', () {
      final response = CriptoYaResponse.fromJson(
        readJsonFixture('criptoya/usdc_bob_1.json'),
      );
      final asks = response.pricesFor(ExchangeDirection.fiatToCrypto);

      expect(response.exchanges, hasLength(5));
      expect(asks, hasLength(2));
      expect(asks.every((price) => price > dec('0')), isTrue);
    });

    test('todos en 0: sin precios', () {
      final response = CriptoYaResponse.fromJson(
        readJsonFixture('criptoya/all_zero.json'),
      );

      expect(response.pricesFor(ExchangeDirection.cryptoToFiat), isEmpty);
    });
  });

  test('ignora entradas inválidas y usa ask/bid si faltan los total*', () {
    final response = CriptoYaResponse.fromJson(const {
      'a': {'ask': 10, 'bid': '9'},
      'b': 'roto',
      'c': {'ask': 'x', 'bid': 1},
    });

    expect(response.exchanges.keys, ['a']);
    expect(response.exchanges['a']!.totalBid, dec('9'));
  });

  test('raíz que no es objeto lanza ParsingException', () {
    for (final json in <Object?>['<html></html>', <Object?>[], null]) {
      expect(
        () => CriptoYaResponse.fromJson(json),
        throwsA(isA<ParsingException>()),
      );
    }
  });
}

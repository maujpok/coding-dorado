import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/prices_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/data_test_utils.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  group('PricesResponse con la respuesta real capturada', () {
    final prices = PricesResponse.fromJson(
      readJsonFixture('eldorado/prices.json'),
    );

    test('VES está en SELL pero no en BUY', () {
      expect(prices.fiatsFor(PriceSide.sell), contains('VES'));
      expect(prices.fiatsFor(PriceSide.buy), isNot(contains('VES')));
      expect(
        () => prices.entryFor(PriceSide.buy, 'VES'),
        throwsA(isA<UnsupportedPairException>()),
      );
    });

    test('las fiat de la app que cotiza El Dorado tienen precio y mínimos', () {
      for (final fiat in ['COP', 'ARS', 'PEN', 'BRL', 'BOB']) {
        for (final side in PriceSide.values) {
          final entry = prices.entryFor(side, fiat);
          expect(entry.price > dec('0'), isTrue, reason: '$fiat ${side.key}');
          expect(entry.inMin, isNotNull, reason: '$fiat ${side.key}');
        }
      }
    });

    test('en SELL el mínimo de entrada es en USDT', () {
      final ves = prices.entryFor(PriceSide.sell, 'VES');
      expect(ves.inMin, dec('5'));
    });
  });

  group('PricesResponse.fromJson tolerante', () {
    test('acepta precios numéricos, limits ausente y minúsculas', () {
      final prices = PricesResponse.fromJson(const {
        'SELL': {
          'ves': {'price': 25},
        },
      });

      final entry = prices.entryFor(PriceSide.sell, 'VES');
      expect(entry.price, dec('25'));
      expect(entry.inMin, isNull);
      expect(prices.fiatsFor(PriceSide.buy), isEmpty);
    });

    test('ignora entradas sin precio válido', () {
      final prices = PricesResponse.fromJson(const {
        'SELL': {
          'VES': {'price': 'n/a'},
          'COP': 'roto',
          'ARS': {'price': '1650.5'},
        },
        'BUY': <String, Object?>{},
      });

      expect(prices.fiatsFor(PriceSide.sell), {'ARS'});
    });

    test('respuesta vacía: ningún par disponible', () {
      final prices = PricesResponse.fromJson(
        readJsonFixture('eldorado/prices_empty.json'),
      );

      expect(
        () => prices.entryFor(PriceSide.sell, 'COP'),
        throwsA(isA<UnsupportedPairException>()),
      );
    });

    test('HTML, listas u objetos sin SELL/BUY lanzan ParsingException', () {
      for (final json in <Object?>[
        readFixture('eldorado/prices_malformed.html'),
        ['SELL'],
        {'data': <String, Object?>{}},
        {'SELL': 'no es un objeto'},
        null,
      ]) {
        expect(
          () => PricesResponse.fromJson(json),
          throwsA(isA<ParsingException>()),
          reason: '$json',
        );
      }
    });
  });
}

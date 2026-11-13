import 'package:decimal/decimal.dart';

/// Precios **ficticios** de El Dorado (fiat por 1 USDT), cercanos al mercado
/// del 2026-11-13. Los usan los mocks de El Dorado y de CriptoYa.
abstract final class MockPrices {
  /// `SELL`: el usuario vende USDT. VES = 25.00 para que la pantalla coincida
  /// con el diseño (5 USDT → 125.00 VES).
  static final Map<String, Decimal> sell = {
    'VES': Decimal.parse('25.00'),
    'COP': Decimal.parse('3300'),
    'ARS': Decimal.parse('1660'),
    'PEN': Decimal.parse('3.42'),
    'BRL': Decimal.parse('5.65'),
    'BOB': Decimal.parse('11.85'),
  };

  /// `BUY = SELL × 1.02`.
  static final Decimal buySpread = Decimal.parse('1.02');

  /// Igual que el API real: VES solo existe en `SELL`.
  static const Set<String> sellOnly = {'VES'};

  /// Mínimo de 5 USDT, como el API real.
  static final Decimal minUsdt = Decimal.fromInt(5);

  static Decimal? sellPrice(String fiat) => sell[fiat];

  static Decimal? buyPrice(String fiat) {
    final price = sell[fiat];
    if (price == null || sellOnly.contains(fiat)) return null;
    return price * buySpread;
  }

  /// Cuerpo con la misma forma que `GET /api/prices`.
  static Map<String, Object?> pricesJson() => {
    'SELL': {
      for (final MapEntry(key: fiat, value: price) in sell.entries)
        fiat: {
          'limits': {
            'in': {'min': minUsdt.toString()},
            'out': {'min': (minUsdt * price).toString()},
          },
          'price': price.toString(),
        },
    },
    'BUY': {
      for (final fiat in sell.keys)
        if (buyPrice(fiat) case final price?)
          fiat: {
            'limits': {
              'in': {'min': (minUsdt * price).toString()},
              'out': {'min': minUsdt.toString()},
            },
            'price': price.toString(),
          },
    },
  };
}

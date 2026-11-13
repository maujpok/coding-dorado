import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:decimal/decimal.dart';

/// Monedas de prueba, independientes del catálogo de la app.
abstract final class TestCurrencies {
  static const usdt = Currency(
    code: 'USDT',
    name: 'Tether',
    symbol: 'USDT',
    type: CurrencyType.crypto,
  );
  static const usdc = Currency(
    code: 'USDC',
    name: 'USD Coin',
    symbol: 'USDC',
    type: CurrencyType.crypto,
  );
  static const ves = Currency(
    code: 'VES',
    name: 'Bolívares',
    symbol: 'Bs',
    type: CurrencyType.fiat,
  );
  static const cop = Currency(
    code: 'COP',
    name: 'Pesos Colombianos',
    symbol: r'COL$',
    type: CurrencyType.fiat,
  );
}

Decimal dec(String value) => Decimal.parse(value);

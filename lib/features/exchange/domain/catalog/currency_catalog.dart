import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';

/// Monedas de la app, con los nombres y símbolos de los sheets del diseño.
/// Es el único lugar donde se agrega una moneda.
abstract final class CurrencyCatalog {
  static const usdt = Currency(
    code: 'USDT',
    name: 'Tether',
    symbol: 'USDT',
    type: CurrencyType.crypto,
    iconAsset: 'assets/cripto_currencies/TATUM-TRON-USDT.png',
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
    iconAsset: 'assets/fiat_currencies/VES.png',
  );
  static const cop = Currency(
    code: 'COP',
    name: 'Pesos Colombianos',
    symbol: r'COL$',
    type: CurrencyType.fiat,
    iconAsset: 'assets/fiat_currencies/COP.png',
  );
  static const ars = Currency(
    code: 'ARS',
    name: 'Pesos Argentinos',
    symbol: r'ARS$',
    type: CurrencyType.fiat,
  );
  static const pen = Currency(
    code: 'PEN',
    name: 'Soles Peruanos',
    symbol: 'S/',
    type: CurrencyType.fiat,
    iconAsset: 'assets/fiat_currencies/PEN.png',
  );
  static const brl = Currency(
    code: 'BRL',
    name: 'Real Brasileño',
    symbol: r'R$',
    type: CurrencyType.fiat,
    iconAsset: 'assets/fiat_currencies/BRL.png',
  );

  /// El mock del diseño dice "Boliviano (R$)", un error de copia: el símbolo
  /// del boliviano es Bs.
  static const bob = Currency(
    code: 'BOB',
    name: 'Boliviano',
    symbol: 'Bs',
    type: CurrencyType.fiat,
  );

  static const List<Currency> cryptos = [usdt, usdc];
  static const List<Currency> fiats = [ves, cop, ars, pen, brl, bob];

  static List<Currency> ofType(CurrencyType type) =>
      type == CurrencyType.crypto ? cryptos : fiats;
}

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
    country: 'Venezuela',
    iconAsset: 'assets/fiat_currencies/VES.png',
  );
  static const cop = Currency(
    code: 'COP',
    name: 'Pesos Colombianos',
    symbol: r'COL$',
    type: CurrencyType.fiat,
    country: 'Colombia',
    iconAsset: 'assets/fiat_currencies/COP.png',
  );
  static const ars = Currency(
    code: 'ARS',
    name: 'Pesos Argentinos',
    symbol: r'ARS$',
    type: CurrencyType.fiat,
    country: 'Argentina',
  );
  static const pen = Currency(
    code: 'PEN',
    name: 'Soles Peruanos',
    symbol: 'S/',
    type: CurrencyType.fiat,
    country: 'Perú',
    iconAsset: 'assets/fiat_currencies/PEN.png',
  );
  static const brl = Currency(
    code: 'BRL',
    name: 'Real Brasileño',
    symbol: r'R$',
    type: CurrencyType.fiat,
    country: 'Brasil',
    iconAsset: 'assets/fiat_currencies/BRL.png',
  );

  /// El mock del diseño dice "Boliviano (R$)", un error de copia: el símbolo
  /// del boliviano es Bs.
  static const bob = Currency(
    code: 'BOB',
    name: 'Boliviano',
    symbol: 'Bs',
    type: CurrencyType.fiat,
    country: 'Bolivia',
  );

  static const List<Currency> cryptos = [usdt, usdc];

  /// Ordenadas alfabéticamente por país, como las muestra el selector FIAT:
  /// Argentina, Bolivia, Brasil, Colombia, Perú, Venezuela.
  static final List<Currency> fiats = List.unmodifiable(
    <Currency>[ves, cop, ars, pen, brl, bob]..sort(compareByCountry),
  );

  /// Compara por país sin distinguir mayúsculas ni tildes ("Perú" = "Peru").
  static int compareByCountry(Currency a, Currency b) =>
      _sortKey(a.country ?? a.name).compareTo(_sortKey(b.country ?? b.name));

  static String _sortKey(String text) {
    const accented = 'áéíóúüñ';
    const plain = 'aeiouun';
    final lower = text.toLowerCase();
    return String.fromCharCodes(
      lower.runes.map((rune) {
        final index = accented.indexOf(String.fromCharCode(rune));
        return index < 0 ? rune : plain.codeUnitAt(index);
      }),
    );
  }

  static List<Currency> ofType(CurrencyType type) =>
      type == CurrencyType.crypto ? cryptos : fiats;
}

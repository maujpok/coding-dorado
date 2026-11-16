import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las fiat van en orden alfabético por país', () {
    expect(
      CurrencyCatalog.fiats.map((c) => '${c.country} (${c.code})'),
      [
        'Argentina (ARS)',
        'Bolivia (BOB)',
        'Brasil (BRL)',
        'Colombia (COP)',
        'Perú (PEN)',
        'Venezuela (VES)',
      ],
    );
    expect(CurrencyCatalog.ofType(CurrencyType.fiat), CurrencyCatalog.fiats);
  });

  test('toda fiat tiene país; las crypto no', () {
    expect(CurrencyCatalog.fiats.every((c) => c.country != null), isTrue);
    expect(CurrencyCatalog.cryptos.every((c) => c.country == null), isTrue);
  });

  test('el orden ignora tildes y mayúsculas', () {
    Currency fiat(String country) => Currency(
      code: country,
      name: country,
      symbol: country,
      type: CurrencyType.fiat,
      country: country,
    );

    expect(
      CurrencyCatalog.compareByCountry(fiat('Perú'), fiat('peru')),
      0,
    );
    expect(
      CurrencyCatalog.compareByCountry(fiat('Ébano'), fiat('Ecuador')),
      lessThan(0),
    );
  });

  test('la lista no se puede modificar', () {
    expect(
      () => CurrencyCatalog.fiats.add(CurrencyCatalog.ves),
      throwsUnsupportedError,
    );
  });
}

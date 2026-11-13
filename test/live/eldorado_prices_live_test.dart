@Tags(['live'])
library;

import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/network/dio_factory.dart';
import 'package:coding_dorado/features/exchange/data/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_prices_data_source.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/prices_response.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contrato contra `GET https://api.eldorado.io/api/prices`. Avisa si El
/// Dorado cambia la forma de la respuesta o la cobertura que la app asume.
void main() {
  const enabled = bool.fromEnvironment('LIVE_TESTS');

  final dio = createDio(baseUrl: AppConfig.defaultEldoradoApiUrl);
  final dataSource = EldoradoPricesDataSource(dio);

  test('la respuesta tiene SELL y BUY con precios parseables', () async {
    final response = await dio.get<Object?>(EldoradoPricesDataSource.path);
    final prices = PricesResponse.fromJson(response.data);

    for (final fiat in ['COP', 'ARS', 'PEN', 'BRL', 'BOB']) {
      for (final side in PriceSide.values) {
        final entry = prices.entryFor(side, fiat);
        expect(entry.price > Decimal.zero, isTrue, reason: '$fiat $side');
        expect(entry.inMin, isNotNull, reason: '$fiat $side');
      }
    }
    expect(prices.fiatsFor(PriceSide.sell), contains('VES'));
  }, skip: !enabled);

  test('USDT → COP cotiza con mínimo', () async {
    final rate = await dataSource.fetchRate(
      pair: ExchangePair(from: CurrencyCatalog.usdt, to: CurrencyCatalog.cop),
      amount: Decimal.fromInt(10),
    );

    expect(rate.rate > Decimal.zero, isTrue);
    expect(rate.minAmount, isNotNull);
  }, skip: !enabled);
}

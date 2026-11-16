@Tags(['live'])
library;

import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/network/dio_factory.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_response.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contrato contra `GET {CRIPTOYA_API_URL}/{coin}/{fiat}/1`, con la URL del
/// `.env`:
///
/// flutter test --dart-define-from-file=.env --dart-define=LIVE_TESTS=true
///   --tags live
void main() {
  const enabled = bool.fromEnvironment('LIVE_TESTS');

  final config = AppConfig.fromEnvironment();
  // Si se piden las pruebas live sin el .env, fallan con un mensaje claro.
  setUpAll(() {
    if (enabled) config.ensureComplete();
  });

  final dio = createDio(baseUrl: config.criptoyaApiUrl);
  final dataSource = CriptoYaRateDataSource(dio);

  test('la respuesta es un objeto de exchanges con bid/ask', () async {
    final pair = ExchangePair(
      from: CurrencyCatalog.usdt,
      to: CurrencyCatalog.ves,
    );
    final response = await dio.get<Object?>(
      CriptoYaRateDataSource.pathFor(pair),
    );
    final parsed = CriptoYaResponse.fromJson(response.data);

    expect(parsed.exchanges, isNotEmpty);
    expect(parsed.pricesFor(pair.direction), isNotEmpty);
  }, skip: !enabled);

  test('USDT → VES cotiza en ambas direcciones', () async {
    final pair = ExchangePair(
      from: CurrencyCatalog.usdt,
      to: CurrencyCatalog.ves,
    );

    final sell = await dataSource.fetchRate(pair: pair, amount: Decimal.one);
    final buy = await dataSource.fetchRate(
      pair: pair.swapped(),
      amount: Decimal.one,
    );

    expect(sell.rate > Decimal.zero, isTrue);
    expect(buy.rate > Decimal.zero, isTrue);
    expect(sell.sampleSize, greaterThan(0));
  }, skip: !enabled);
}

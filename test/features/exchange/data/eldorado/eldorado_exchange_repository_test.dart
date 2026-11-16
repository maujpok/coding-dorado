import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_prices_data_source.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/data_test_utils.dart';
import '../../../../helpers/fake_apis/fake_eldorado_prices_api.dart';
import '../../../../helpers/test_currencies.dart';

/// Repositorio de El Dorado con la API falsa en el escenario pedido.
EldoradoExchangeRepository repositoryFor(EldoradoPricesScenario scenario) =>
    EldoradoExchangeRepository(
      EldoradoPricesDataSource(
        fakeDio(FakeEldoradoPricesApi(scenario: scenario)),
      ),
    );

void main() {
  final usdtToVes = ExchangePair(
    from: TestCurrencies.usdt,
    to: TestCurrencies.ves,
  );

  test('identifica al proveedor', () {
    expect(
      repositoryFor(EldoradoPricesScenario.success).provider,
      RateProvider.eldorado,
    );
  });

  test('success → Ok(ExchangeRate)', () async {
    final result = await repositoryFor(
      EldoradoPricesScenario.success,
    ).getRate(pair: usdtToVes, amount: dec('5'));

    expect(
      result,
      Ok(
        ExchangeRate(
          fiatPerCrypto: dec('25'),
          minAmount: dec('5'),
          estimatedTime: const Duration(minutes: 10),
        ),
      ),
    );
  });

  final expectations = <EldoradoPricesScenario, Failure>{
    EldoradoPricesScenario.empty: const PairUnavailableFailure(),
    EldoradoPricesScenario.serverError: const ServerFailure(503),
    EldoradoPricesScenario.timeout: const TimeoutFailure(),
    EldoradoPricesScenario.malformed: const ParsingFailure(),
  };
  for (final MapEntry(key: scenario, value: failure) in expectations.entries) {
    test('${scenario.name} → ${failure.runtimeType}', () async {
      final result = await repositoryFor(
        scenario,
      ).getRate(pair: usdtToVes, amount: dec('5'));

      expect(result, Err<ExchangeRate>(failure));
    });
  }

  test('getAvailability nunca falla: ante error devuelve unknown', () async {
    final availability = await repositoryFor(
      EldoradoPricesScenario.serverError,
    ).getAvailability();

    expect(availability, const PairAvailability.unknown());
  });
}

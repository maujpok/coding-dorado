import 'dart:math';

import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/checkout/data/simulated_transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'fake_apis/fake_criptoya_api.dart';
import 'fake_apis/fake_eldorado_prices_api.dart';
import 'fake_apis/fake_orderbook_api.dart';

extension PumpApp on WidgetTester {
  /// Monta [child] con el tema, la localización y un Scaffold.
  Future<void> pumpApp(Widget child) => pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

/// Dependencias reales de la app con las APIs de ambos proveedores
/// reemplazadas por [FakeEldoradoPricesApi] y [FakeCriptoYaApi] (o
/// [FakeOrderbookApi] si [config] usa el API de órdenes): sin red.
GetIt fakeApiDependencies({
  EldoradoPricesScenario eldorado = EldoradoPricesScenario.success,
  CriptoYaScenario criptoya = CriptoYaScenario.success,
  OrderbookScenario orderbook = OrderbookScenario.success,
  AppConfig config = const AppConfig.defaults(),
}) {
  final getIt = GetIt.asNewInstance();
  configureDependencies(
    getIt,
    config,
    httpInterceptors: {
      RateProvider.eldorado: [
        if (config.eldoradoSource == EldoradoSource.orderbook)
          FakeOrderbookApi(scenario: orderbook)
        else
          FakeEldoradoPricesApi(scenario: eldorado),
      ],
      RateProvider.criptoya: [FakeCriptoYaApi(scenario: criptoya)],
    },
  );
  return getIt;
}

/// Fábrica de blocs sobre la pila real de [getIt], sin debounce.
ExchangeBloc Function(RateProvider) testBlocFactory(GetIt getIt) =>
    (provider) => ExchangeBloc(
      getQuote: getIt.getExchangeQuote(provider),
      repository: getIt.exchangeRepository(provider),
      quoteDebounce: Duration.zero,
    );

/// Fecha y hora fijas de los cambios simulados en las pruebas.
final testCompletedAt = DateTime(2026, 11, 14, 9, 24);

/// Ejecución simulada instantánea y determinista (fecha fija, mismo ID).
SubmitExchange instantSubmitExchange() => SubmitExchange(
  SimulatedTransactionRepository(
    latency: Duration.zero,
    clock: () => testCompletedAt,
    random: Random(7),
  ),
);

/// La app completa sobre las dependencias de [getIt].
App testApp(GetIt getIt, {SubmitExchange? submitExchange}) => App(
  createExchangeBloc: testBlocFactory(getIt),
  compareQuotes: getIt<CompareQuotes>(),
  submitExchange: submitExchange ?? instantSubmitExchange(),
);

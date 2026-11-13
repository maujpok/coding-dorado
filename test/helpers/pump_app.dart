import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

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

/// Configuración con ambos proveedores en mock y sin latencia.
AppConfig mockAppConfig({
  String eldorado = 'success',
  String criptoya = 'success',
}) => AppConfig(
  eldoradoApiUrl: AppConfig.defaultEldoradoApiUrl,
  criptoyaApiUrl: AppConfig.defaultCriptoyaApiUrl,
  useMock: true,
  mockScenarioEldorado: eldorado,
  mockScenarioCriptoya: criptoya,
  mockLatency: Duration.zero,
  eldoradoSource: EldoradoSource.prices,
  orderbookApiUrl: '',
);

/// Fábrica de blocs sobre la pila real (DI + mocks HTTP), sin debounce.
ExchangeBloc Function(RateProvider) mockBlocFactory(GetIt getIt) =>
    (provider) => ExchangeBloc(
      getQuote: getIt.getExchangeQuote(provider),
      repository: getIt.exchangeRepository(provider),
      quoteDebounce: Duration.zero,
      submitDelay: Duration.zero,
    );

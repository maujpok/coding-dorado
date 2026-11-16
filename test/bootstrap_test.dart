import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/config_error_app.dart';
import 'package:coding_dorado/bootstrap.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('sin el .env muestra qué falta y cómo ejecutar, sin quedarse '
      'en el splash', (tester) async {
    final getIt = GetIt.asNewInstance();
    const config = AppConfig(eldoradoApiUrl: '', criptoyaApiUrl: '');

    final root = rootApp(config, getIt);
    await tester.pumpWidget(root);
    await tester.pumpAndSettle();

    expect(root, isA<ConfigErrorApp>());
    expect(find.text('Falta la configuración'), findsOneWidget);
    expect(
      find.textContaining('ELDORADO_API_URL, CRIPTOYA_API_URL'),
      findsOneWidget,
    );
    expect(
      find.text('flutter run --dart-define-from-file=.env'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    expect(
      getIt.isRegistered<ExchangeRepository>(
        instanceName: RateProvider.eldorado.name,
      ),
      isFalse,
      reason: 'sin configuración no se arman las dependencias',
    );
  });

  testWidgets('la pantalla de configuración no desborda en 320 pt', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(640, 1136)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ConfigErrorApp(missingKeys: ['ELDORADO_API_URL']),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('con la configuración completa arma las dependencias y la app', () {
    final getIt = GetIt.asNewInstance();

    final root = rootApp(testAppConfig, getIt);

    expect(root, isA<App>());
    expect(getIt<AppConfig>(), testAppConfig);
  });
}

@Tags(['golden'])
library;

import 'dart:io';

import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_processing_page.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_pair_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../helpers/pump_app.dart';

/// Capturas a 402×874 pt @2x (el tamaño de los mocks) con las fuentes reales
/// y datos del mock HTTP. El render de fuentes cambia según el sistema
/// operativo, así que no corren por defecto:
///
/// flutter test --dart-define=GOLDENS=true --tags golden [--update-goldens]
void main() {
  const enabled = bool.fromEnvironment('GOLDENS');

  setUpAll(_loadFonts);

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(804, 1748)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final getIt = GetIt.asNewInstance();
    configureDependencies(getIt, mockAppConfig());
    await tester.pumpWidget(mockApp(getIt));
    await tester.pumpAndSettle();
  }

  Future<void> typeAmount(WidgetTester tester, String amount) async {
    await tester.enterText(find.byType(TextField).hitTestable(), amount);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> expectGolden(WidgetTester tester, String name) async {
    await _precacheImages(tester);
    await expectLater(find.byType(App), matchesGoldenFile('screens/$name'));
  }

  testWidgets('calculadora El Dorado: 5.00 USDT → VES', (tester) async {
    await pumpHome(tester);
    await typeAmount(tester, '5.00');
    await expectGolden(tester, 'home_eldorado.png');
  }, skip: !enabled);

  testWidgets('selector FIAT', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byType(CurrencySelectorButton).last);
    await tester.pumpAndSettle();
    await expectGolden(tester, 'picker_fiat.png');
  }, skip: !enabled);

  testWidgets('selector Cripto', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byType(CurrencySelectorButton).first);
    await tester.pumpAndSettle();
    await expectGolden(tester, 'picker_crypto.png');
  }, skip: !enabled);

  testWidgets('comparación de cotizaciones', (tester) async {
    await pumpHome(tester);
    await typeAmount(tester, '5.00');
    await tester.tap(find.text('Comparar cotizaciones').hitTestable());
    await tester.pumpAndSettle();
    await expectGolden(tester, 'comparison.png');
  }, skip: !enabled);

  Future<void> openConfirmation(WidgetTester tester) async {
    await pumpHome(tester);
    await typeAmount(tester, '5.00');
    await tester.tap(find.text('Simular').hitTestable());
    await tester.pumpAndSettle();
  }

  testWidgets('confirmación del cambio', (tester) async {
    await openConfirmation(tester);
    await expectGolden(tester, 'confirmation.png');
  }, skip: !enabled);

  testWidgets('procesando el cambio (segundo paso en curso)', (tester) async {
    await openConfirmation(tester);
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    // La animación es infinita: sin pumpAndSettle.
    await expectLater(
      find.byType(App),
      matchesGoldenFile('screens/processing.png'),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }, skip: !enabled);

  testWidgets('cambio exitoso', (tester) async {
    await openConfirmation(tester);
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(CheckoutProcessingPage.successHold);
    await tester.pumpAndSettle();
    await expectGolden(tester, 'success.png');
  }, skip: !enabled);

  testWidgets('calculadora CriptoYa: 5.00 USDT → VES', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    await typeAmount(tester, '5.00');
    await expectGolden(tester, 'home_criptoya.png');
  }, skip: !enabled);
}

Future<void> _loadFonts() async {
  final rubik = FontLoader('Rubik');
  for (final weight in ['Regular', 'Medium', 'SemiBold']) {
    rubik.addFont(rootBundle.load('assets/fonts/Rubik-$weight.ttf'));
  }
  await rubik.load();

  final icons = _materialIconsFont();
  if (icons != null) {
    await (FontLoader(
          'MaterialIcons',
        )..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync()))))
        .load();
  }
}

/// La fuente de íconos viene con el SDK de Flutter.
File? _materialIconsFont() {
  const relative =
      'bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final file = File('$root/$relative');
    if (file.existsSync()) return file;
  }
  // Sin FLUTTER_ROOT: subir desde el ejecutable de pruebas.
  var dir = File(Platform.resolvedExecutable).parent;
  while (dir.parent.path != dir.path) {
    final file = File('${dir.path}/$relative');
    if (file.existsSync()) return file;
    dir = dir.parent;
  }
  return null;
}

Future<void> _precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await tester.pumpAndSettle();
}

import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_processing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance();
    configureDependencies(getIt, mockAppConfig());
  });

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(804, 1748)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(mockApp(getIt));
    await tester.pumpAndSettle();
  }

  Finder visibleField() => find.byType(TextField).hitTestable();

  testWidgets('muestra una pestaña por proveedor, El Dorado activa', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('El Dorado'), findsOneWidget);
    expect(find.text('CriptoYa'), findsOneWidget);
    expect(find.text('Fuente: El Dorado · tasa indicativa'), findsOneWidget);
  });

  testWidgets('cada pestaña conserva su monto al cambiar', (tester) async {
    await pumpHome(tester);

    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();
    expect(find.textContaining('125.00').hitTestable(), findsOneWidget);

    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    await tester.enterText(visibleField(), '10');
    await tester.pumpAndSettle();
    expect(find.textContaining('252.50').hitTestable(), findsOneWidget);

    await tester.tap(find.text('El Dorado'));
    await tester.pumpAndSettle();
    expect(find.text('5').hitTestable(), findsOneWidget);
    expect(find.textContaining('125.00').hitTestable(), findsOneWidget);
  });

  testWidgets('comparar: insignia en el ganador y "Usar CriptoYa" cambia de '
      'pestaña con el mismo par y monto', (tester) async {
    await pumpHome(tester);
    expect(
      tester.widget<DsLink>(find.byType(DsLink).hitTestable()).onPressed,
      isNull,
      reason: 'sin monto no se compara',
    );

    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comparar cotizaciones').hitTestable());
    await tester.pumpAndSettle();

    expect(find.text('Mejor opción'), findsOneWidget);
    expect(find.textContaining('≈ 126.25 VES'), findsOneWidget);
    expect(find.textContaining('+1.25 VES (+1.00 %)'), findsOneWidget);

    await tester.tap(find.text('Usar CriptoYa'));
    await tester.pumpAndSettle();

    expect(find.text('Mejor opción'), findsNothing);
    expect(find.text('5').hitTestable(), findsOneWidget);
    expect(find.textContaining('126.25').hitTestable(), findsOneWidget);
  });

  testWidgets('comparar con un proveedor caído muestra el resultado parcial', (
    tester,
  ) async {
    getIt = GetIt.asNewInstance();
    configureDependencies(getIt, mockAppConfig(criptoya: 'rate_limited'));
    await pumpHome(tester);

    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comparar cotizaciones').hitTestable());
    await tester.pumpAndSettle();

    expect(
      find.text('Demasiadas consultas. Espera un momento.'),
      findsOneWidget,
    );
    expect(
      find.text('Solo El Dorado tiene cotización para este par.'),
      findsOneWidget,
    );
    expect(find.text('Mejor opción'), findsOneWidget);
  });

  testWidgets('título "Calculadora" justo encima de la tarjeta, debajo de '
      'las pestañas', (tester) async {
    await pumpHome(tester);

    final title = find.text('Calculadora').hitTestable();
    expect(title, findsOneWidget);
    final card = find.byType(DsCard).hitTestable().first;
    final titleRect = tester.getRect(title);
    final cardRect = tester.getRect(card);

    expect(
      titleRect.top,
      greaterThan(tester.getBottomLeft(find.text('El Dorado')).dy),
    );
    expect(cardRect.top - titleRect.bottom, inInclusiveRange(0, 16));
    expect(titleRect.left, closeTo(cardRect.left, 1));

    // Cada pestaña tiene su título sobre su propia tarjeta.
    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    expect(find.text('Calculadora').hitTestable(), findsOneWidget);
  });

  testWidgets('título y tarjeta en el mismo lugar en ambas pestañas, aunque '
      'la tarjeta de CriptoYa no tenga tiempo estimado', (tester) async {
    await pumpHome(tester);
    Rect titleRect() => tester.getRect(find.text('Calculadora').hitTestable());
    Rect cardRect() => tester.getRect(find.byType(DsCard).hitTestable().first);

    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();
    expect(find.text('Tiempo estimado').hitTestable(), findsOneWidget);
    final eldoradoTitle = titleRect();
    final eldoradoCard = cardRect();

    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();
    expect(find.text('Tiempo estimado').hitTestable(), findsNothing);
    expect(titleRect(), eldoradoTitle);
    expect(cardRect().topLeft, eldoradoCard.topLeft);
    expect(cardRect().height, lessThan(eldoradoCard.height));

    // Un mensaje dentro de la tarjeta la alarga hacia abajo sin moverla.
    await tester.tap(find.text('El Dorado'));
    await tester.pumpAndSettle();
    await tester.enterText(visibleField(), '1');
    await tester.pumpAndSettle();
    expect(find.textContaining('Mínimo').hitTestable(), findsOneWidget);
    expect(titleRect(), eldoradoTitle);
    expect(cardRect().topLeft, eldoradoCard.topLeft);
  });

  testWidgets('el fondo de CriptoYa tiene otro color que el de El Dorado', (
    tester,
  ) async {
    await pumpHome(tester);
    Color? decoration() =>
        tester.widget<DsBackground>(find.byType(DsBackground)).decorationColor;

    expect(decoration(), AppColors.light.backgroundDecoration);

    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    expect(decoration(), AppColors.light.backgroundDecorationSecondary);
    expect(decoration(), isNot(AppColors.light.backgroundDecoration));

    await tester.tap(find.text('El Dorado'));
    await tester.pumpAndSettle();
    expect(decoration(), AppColors.light.backgroundDecoration);
  });

  testWidgets('Simular → Confirmar → procesamiento → comprobante → inicio', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simular').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Confirma tu cambio'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Confirma tu cambio'), findsNothing);
    expect(find.text('Procesando tu cambio'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(CheckoutProcessingPage.successHold);
    await tester.pumpAndSettle();
    expect(find.text('¡Cambio exitoso!'), findsOneWidget);
    expect(find.text('125.00 VES'), findsOneWidget);
    expect(find.text('por 5.00 USDT'), findsOneWidget);
    expect(find.text('1 USDT = 25.00 VES'), findsOneWidget);

    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Calculadora').hitTestable(), findsOneWidget);

    // La calculadora vuelve a empezar: sin monto y con el par inicial.
    final field = tester.widget<TextField>(visibleField());
    expect(field.controller!.text, isEmpty);
    expect(find.text('125.00').hitTestable(), findsNothing);
    expect(find.text('—').hitTestable(), findsNWidgets(3));
  });

  testWidgets('el reinicio tras un cambio solo afecta a esa pestaña', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    await tester.enterText(visibleField(), '10');
    await tester.pumpAndSettle();
    await tester.tap(find.text('El Dorado'));
    await tester.pumpAndSettle();
    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simular').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(visibleField()).controller!.text, isEmpty);
    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    expect(find.text('10').hitTestable(), findsOneWidget);
  });

  testWidgets('el comprobante de CriptoYa indica la fuente', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simular').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('¡Cambio exitoso!'), findsOneWidget);
    expect(find.text('CriptoYa'), findsOneWidget);
    expect(find.text('126.25 VES'), findsOneWidget);
  });
}

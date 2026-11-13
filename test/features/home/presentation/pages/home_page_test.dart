import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
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
    await tester.pumpWidget(
      App(
        createExchangeBloc: mockBlocFactory(getIt),
        compareQuotes: getIt<CompareQuotes>(),
      ),
    );
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
}

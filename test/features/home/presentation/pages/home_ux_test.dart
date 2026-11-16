import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_pair_selector.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_picker_sheet.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../helpers/fake_exchange_repository.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(804, 1748),
    bool showMockBanner = false,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final getIt = GetIt.asNewInstance();
    configureDependencies(getIt, mockAppConfig());
    await tester.pumpWidget(mockApp(getIt, showMockBanner: showMockBanner));
    await tester.pumpAndSettle();
  }

  Finder visibleField() => find.byType(TextField).hitTestable();

  DsPrimaryButton exchangeButton(WidgetTester tester) =>
      tester.widget(find.byType(DsPrimaryButton).hitTestable());

  testWidgets('monto bajo el mínimo: aviso junto al campo y Simular '
      'deshabilitado', (tester) async {
    await pumpHome(tester);

    await tester.enterText(visibleField(), '4');
    await tester.pumpAndSettle();

    expect(find.text('Mínimo 5.00 USDT').hitTestable(), findsOneWidget);
    expect(find.text('Reintentar').hitTestable(), findsNothing);
    expect(exchangeButton(tester).onPressed, isNull);
  });

  testWidgets('par no disponible en El Dorado: "Ver en CriptoYa" lleva el '
      'mismo par y monto', (tester) async {
    await pumpHome(tester);
    await tester.enterText(visibleField(), '100');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwapButton).hitTestable());
    await tester.pumpAndSettle();

    expect(
      find.text('Este par no está disponible en El Dorado.').hitTestable(),
      findsOneWidget,
    );
    expect(find.text('Elegir otra moneda').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Ver en CriptoYa').hitTestable());
    await tester.pumpAndSettle();

    // CriptoYa: 100 VES ÷ 25.75 = 3.88 USDT.
    expect(find.text('100').hitTestable(), findsOneWidget);
    expect(find.textContaining('≈ 3.88 USDT').hitTestable(), findsOneWidget);
  });

  testWidgets('los sheets de El Dorado deshabilitan USDC; los de CriptoYa no', (
    tester,
  ) async {
    await pumpHome(tester);

    CurrencyListTile usdcTile() => tester.widget(
      find.byWidgetPredicate(
        (w) => w is CurrencyListTile && w.currency.code == 'USDC',
      ),
    );

    await tester.tap(find.byType(CurrencySelectorButton).hitTestable().first);
    await tester.pumpAndSettle();
    expect(usdcTile().enabled, isFalse);
    expect(find.textContaining('No disponible'), findsOneWidget);
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CriptoYa'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CurrencySelectorButton).hitTestable().first);
    await tester.pumpAndSettle();
    expect(usdcTile().enabled, isTrue);
  });

  testWidgets('texto al 130 % en una pantalla de 320 pt: sin desbordes', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHome(tester, size: const Size(640, 1136));

    await tester.enterText(visibleField(), '12345.67');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Comparar cotizaciones').hitTestable());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.text('Mejor opción'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simular').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Confirma tu cambio'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // En pantallas chicas el sheet hace scroll hasta "Confirmar".
    await tester.ensureVisible(find.text('Confirmar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('¡Cambio exitoso!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar fuera del campo cierra el teclado', (tester) async {
    await pumpHome(tester);

    await tester.tap(visibleField());
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.context?.widget, isNotNull);
    final focusedBefore = FocusManager.instance.primaryFocus;

    await tester.tapAt(const Offset(30, 1600 / 2));
    await tester.pump();

    expect(FocusManager.instance.primaryFocus, isNot(focusedBefore));
  });

  testWidgets('banner MOCK cuando se pide', (tester) async {
    await pumpHome(tester, showMockBanner: true);

    expect(find.byType(Banner), findsOneWidget);
  });

  testWidgets('al volver a la app se recotiza', (tester) async {
    final repository = FakeExchangeRepository(
      onGetRate: (_, _) async => Ok(ExchangeRate(fiatPerCrypto: dec('25'))),
    );
    tester.view
      ..physicalSize = const Size(804, 1748)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      App(
        createExchangeBloc: (_) => ExchangeBloc(
          getQuote: GetExchangeQuote(repository),
          repository: repository,
          quoteDebounce: Duration.zero,
        ),
        compareQuotes: CompareQuotes({
          RateProvider.eldorado: GetExchangeQuote(repository),
        }),
        submitExchange: instantSubmitExchange(),
      ),
    );
    await tester.enterText(visibleField(), '5');
    await tester.pumpAndSettle();
    final callsBefore = repository.calls.length;

    // resumed → inactive → hidden → paused, y de vuelta.
    [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();

    expect(repository.calls.length, greaterThan(callsBefore));
    expect(repository.calls.last.forceRefresh, isFalse);
  });
}

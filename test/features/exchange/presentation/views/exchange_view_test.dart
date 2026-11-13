import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/views/exchange_view.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_pair_selector.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late GetIt getIt;
  late ExchangeBloc bloc;

  Future<void> pumpView(WidgetTester tester, RateProvider provider) async {
    tester.view
      ..physicalSize = const Size(804, 1748)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    getIt = GetIt.asNewInstance();
    configureDependencies(getIt, mockAppConfig());
    // El árbol crea y cierra el bloc: en testWidgets el tiempo es simulado y
    // un `await bloc.close()` directo no avanza.
    bloc = mockBlocFactory(getIt)(provider);
    await tester.pumpApp(
      BlocProvider(
        create: (_) => bloc,
        child: ExchangeView(provider: provider),
      ),
    );
  }

  DsPrimaryButton exchangeButton(WidgetTester tester) =>
      tester.widget(find.byType(DsPrimaryButton));

  testWidgets('muestra la calculadora del diseño sin monto', (tester) async {
    await pumpView(tester, RateProvider.eldorado);

    for (final text in [
      'TENGO',
      'QUIERO',
      'USDT',
      'VES',
      'Tasa estimada',
      'Recibirás',
      'Tiempo estimado',
      'Cambiar',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    expect(exchangeButton(tester).onPressed, isNull);
  });

  testWidgets('5 USDT → VES muestra tasa, monto y tiempo', (tester) async {
    await pumpView(tester, RateProvider.eldorado);

    await tester.enterText(find.byType(TextField), '5');
    await tester.pumpAndSettle();

    expect(find.textContaining('≈ 25.00 VES'), findsOneWidget);
    expect(find.textContaining('≈ 125.00 VES'), findsOneWidget);
    expect(find.textContaining('≈ 10 Min'), findsOneWidget);
    expect(exchangeButton(tester).onPressed, isNotNull);
  });

  testWidgets('Cambiar muestra la confirmación simulada', (tester) async {
    await pumpView(tester, RateProvider.eldorado);
    await tester.enterText(find.byType(TextField), '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DsPrimaryButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Simulación'), findsOneWidget);
  });

  testWidgets('el selector QUIERO abre FIAT y aplica la moneda elegida', (
    tester,
  ) async {
    await pumpView(tester, RateProvider.eldorado);

    await tester.tap(find.byType(CurrencySelectorButton).last);
    await tester.pumpAndSettle();

    expect(find.text('FIAT'), findsOneWidget);
    final selectedTile = tester.widget<CurrencyListTile>(
      find.byWidgetPredicate(
        (w) => w is CurrencyListTile && w.currency == CurrencyCatalog.ves,
      ),
    );
    expect(selectedTile.selected, isTrue);

    await tester.tap(find.text('COP'));
    await tester.pumpAndSettle();

    expect(find.text('FIAT'), findsNothing);
    expect(
      bloc.state.pair,
      ExchangePair(from: CurrencyCatalog.usdt, to: CurrencyCatalog.cop),
    );
  });

  testWidgets('el selector TENGO abre Cripto', (tester) async {
    await pumpView(tester, RateProvider.eldorado);

    await tester.tap(find.byType(CurrencySelectorButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Cripto'), findsOneWidget);
    expect(find.text('USD Coin (USDC)'), findsOneWidget);
  });

  testWidgets('en CriptoYa no hay fila de tiempo estimado', (tester) async {
    await pumpView(tester, RateProvider.criptoya);

    await tester.enterText(find.byType(TextField), '5');
    await tester.pumpAndSettle();

    expect(find.textContaining('126.25'), findsOneWidget);
    expect(find.text('Tiempo estimado'), findsNothing);
    expect(find.textContaining('mediana de 3 exchanges'), findsOneWidget);
  });

  testWidgets('el formateador rechaza más de 2 decimales y letras', (
    tester,
  ) async {
    await pumpView(tester, RateProvider.eldorado);

    await tester.enterText(find.byType(TextField), '12.345');
    expect(find.text('12.345'), findsNothing);
    await tester.enterText(find.byType(TextField), '12.34');
    expect(find.text('12.34'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abc');
    expect(find.text('12.34'), findsOneWidget);
  });
}

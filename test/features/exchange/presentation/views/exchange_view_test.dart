import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/views/exchange_view.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/confirmation_fields.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_pair_selector.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_currencies.dart';

void main() {
  late GetIt getIt;
  late ExchangeBloc bloc;
  late List<ExchangeQuote> confirmed;

  Future<void> pumpView(WidgetTester tester, RateProvider provider) async {
    confirmed = [];
    tester.view
      ..physicalSize = const Size(804, 1748)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    getIt = fakeApiDependencies();
    // El árbol crea y cierra el bloc: en testWidgets el tiempo es simulado y
    // un `await bloc.close()` directo no avanza.
    bloc = testBlocFactory(getIt)(provider);
    await tester.pumpApp(
      BlocProvider(
        create: (_) => bloc,
        child: ExchangeView(provider: provider, onConfirmed: confirmed.add),
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
      'Simular',
      'Calculadora',
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

  group('confirmación', () {
    Finder sheetField() => find.byType(TextField).hitTestable();

    DsPrimaryButton confirmButton(WidgetTester tester) => tester.widget(
      find.widgetWithText(DsPrimaryButton, 'Confirmar'),
    );

    Future<void> openConfirmation(WidgetTester tester) async {
      await pumpView(tester, RateProvider.eldorado);
      await tester.enterText(find.byType(TextField), '5');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DsPrimaryButton));
      await tester.pumpAndSettle();
    }

    testWidgets('Simular abre la confirmación: tres filas editables, el '
        'detalle, Confirmar y Cancelar', (tester) async {
      await openConfirmation(tester);

      expect(find.text('Confirma tu cambio'), findsOneWidget);
      final rows = [
        'Moneda que entregas',
        'Moneda que recibes',
        'Cantidad',
      ];
      for (final text in [
        ...rows,
        'Fuente',
        'Confirmar',
        'Cancelar',
        'Operación simulada: no se mueve dinero real.',
      ]) {
        expect(find.text(text).hitTestable(), findsOneWidget, reason: text);
      }
      // Las filas van en orden, una debajo de la otra.
      final tops = [
        for (final text in rows) tester.getTopLeft(find.text(text)).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));

      final fields = tester.widgetList<CurrencyField>(
        find.byType(CurrencyField),
      );
      expect(fields.map((f) => f.currency), [
        CurrencyCatalog.usdt,
        CurrencyCatalog.ves,
      ]);
      expect(find.text('Tether').hitTestable(), findsOneWidget);
      expect(find.text('Bolívares').hitTestable(), findsOneWidget);
      expect(find.text('5').hitTestable(), findsOneWidget);
      expect(find.textContaining('≈ 125.00 VES').hitTestable(), findsOneWidget);
      expect(find.text('El Dorado').hitTestable(), findsOneWidget);
      expect(confirmButton(tester).onPressed, isNotNull);
    });

    testWidgets('editar la cantidad recotiza y queda en la calculadora', (
      tester,
    ) async {
      await openConfirmation(tester);

      await tester.enterText(sheetField(), '8');
      await tester.pumpAndSettle();

      expect(find.textContaining('≈ 200.00 VES').hitTestable(), findsOneWidget);
      expect(bloc.state.amount, dec('8'));
      expect(bloc.state.amountText, '8');
    });

    testWidgets('editar la moneda que recibes', (tester) async {
      await openConfirmation(tester);

      await tester.tap(find.byType(CurrencyField).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('COP'));
      await tester.pumpAndSettle();

      expect(find.text('Confirma tu cambio'), findsOneWidget);
      // 5 USDT × 3300 = 16,500.00 COP.
      expect(
        find.textContaining('≈ 16,500.00 COP').hitTestable(),
        findsOneWidget,
      );
      expect(bloc.state.pair.to, CurrencyCatalog.cop);
    });

    testWidgets('"Invertir" da vuelta el par', (tester) async {
      await openConfirmation(tester);

      await tester.tap(find.text('Invertir'));
      await tester.pumpAndSettle();

      expect(
        bloc.state.pair,
        ExchangePair(from: CurrencyCatalog.ves, to: CurrencyCatalog.usdt),
      );
      final fields = tester.widgetList<CurrencyField>(
        find.byType(CurrencyField),
      );
      expect(fields.first.currency, CurrencyCatalog.ves);
    });

    testWidgets('bajo el mínimo no se puede confirmar', (tester) async {
      await openConfirmation(tester);

      await tester.enterText(sheetField(), '4');
      await tester.pumpAndSettle();

      expect(find.text('Mínimo 5.00 USDT').hitTestable(), findsOneWidget);
      expect(confirmButton(tester).onPressed, isNull);
    });

    testWidgets('Cancelar cierra sin confirmar', (tester) async {
      await openConfirmation(tester);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirma tu cambio'), findsNothing);
      expect(confirmed, isEmpty);
    });

    testWidgets('Confirmar devuelve la cotización vigente', (tester) async {
      await openConfirmation(tester);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirma tu cambio'), findsNothing);
      expect(confirmed, hasLength(1));
      expect(confirmed.single.amount, dec('5'));
      expect(confirmed.single.receiveAmount, dec('125'));
      expect(confirmed.single.provider, RateProvider.eldorado);
    });
  });

  testWidgets('el selector QUIERO abre FIAT y aplica la moneda elegida', (
    tester,
  ) async {
    await pumpView(tester, RateProvider.eldorado);

    await tester.tap(find.byType(CurrencySelectorButton).last);
    await tester.pumpAndSettle();

    expect(find.text('FIAT'), findsOneWidget);
    expect(
      tester
          .widgetList<CurrencyListTile>(find.byType(CurrencyListTile))
          .map((tile) => tile.currency.code),
      ['ARS', 'BOB', 'BRL', 'COP', 'PEN', 'VES'],
      reason: 'alfabético por país',
    );
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

  testWidgets('el selector se ajusta a la lista: sin espacio vacío abajo', (
    tester,
  ) async {
    await pumpView(tester, RateProvider.eldorado);

    for (final selector in [
      find.byType(CurrencySelectorButton).first,
      find.byType(CurrencySelectorButton).last,
    ]) {
      await tester.tap(selector);
      await tester.pumpAndSettle();

      final sheet = tester.getRect(find.byType(BottomSheet));
      final lastTile = tester.getRect(find.byType(CurrencyListTile).last);
      expect(sheet.bottom - lastTile.bottom, lessThanOrEqualTo(AppSpacing.sm));
      expect(sheet.height, lessThan(874 * AppSizes.pickerSheetMaxHeightFactor));

      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('el selector TENGO abre Cripto solo con lo que la fuente '
      'cotiza', (tester) async {
    await pumpView(tester, RateProvider.eldorado);
    bloc.add(const ExchangeStarted());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CurrencySelectorButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Cripto'), findsOneWidget);
    expect(find.text('Tether (USDT)'), findsOneWidget);
    expect(find.text('USD Coin (USDC)'), findsNothing);
  });

  group('CurrencyPickerList', () {
    Future<List<String>> visibleCodes(
      WidgetTester tester, {
      required Currency selected,
      bool Function(Currency)? isAvailable,
    }) async {
      await tester.pumpApp(
        CurrencyPickerList(
          currencies: CurrencyCatalog.cryptos,
          selected: selected,
          isAvailable: isAvailable,
          onSelected: (_) {},
        ),
      );
      return tester
          .widgetList<CurrencyListTile>(find.byType(CurrencyListTile))
          .map((tile) => tile.currency.code)
          .toList();
    }

    testWidgets('sin información de disponibilidad muestra todas', (
      tester,
    ) async {
      expect(await visibleCodes(tester, selected: CurrencyCatalog.usdt), [
        'USDT',
        'USDC',
      ]);
    });

    testWidgets('oculta las no disponibles, sin la etiqueta "No disponible"', (
      tester,
    ) async {
      expect(
        await visibleCodes(
          tester,
          selected: CurrencyCatalog.usdt,
          isAvailable: (currency) => currency != CurrencyCatalog.usdc,
        ),
        ['USDT'],
      );
      expect(find.textContaining('No disponible'), findsNothing);
    });

    testWidgets('la seleccionada se muestra aunque no esté disponible', (
      tester,
    ) async {
      expect(
        await visibleCodes(
          tester,
          selected: CurrencyCatalog.usdc,
          isAvailable: (currency) => currency != CurrencyCatalog.usdc,
        ),
        ['USDT', 'USDC'],
      );
    });
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

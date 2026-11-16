import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/checkout/data/simulated_transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_processing_page.dart';
import 'package:coding_dorado/features/checkout/presentation/widgets/processing_steps.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_quotes.dart';

class _FailingOnceRepository implements TransactionRepository {
  final SubmitExchange _delegate = instantSubmitExchange();
  int calls = 0;

  @override
  Future<Result<ExchangeTransaction>> submit(ExchangeQuote quote) async =>
      calls++ == 0 ? const Err(NetworkFailure()) : _delegate(quote);
}

void main() {
  const steps = [
    'Validando la cotización',
    'Ejecutando el cambio',
    'Confirmando la transacción',
  ];

  /// Una pantalla con "Iniciar" que abre el procesamiento, como la home.
  Future<void> startCheckout(
    WidgetTester tester, {
    SubmitExchange? submitExchange,
  }) async {
    tester.view
      ..physicalSize = const Size(804, 1748)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            CheckoutProcessingPage.route(
              quote: usdtToArsQuote(),
              submitExchange: submitExchange ?? instantSubmitExchange(),
            ),
          ),
          child: const Text('Iniciar'),
        ),
      ),
    );
    await tester.tap(find.text('Iniciar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Termina la animación mínima, la pausa final y la transición.
  Future<void> finishProcessing(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(CheckoutProcessingPage.successHold);
    await tester.pumpAndSettle();
  }

  String? semanticsOf(WidgetTester tester, String step) {
    final node = tester.getSemantics(find.text(step));
    return node.label;
  }

  testWidgets('procesa con animación y pasos, sin poder salir', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await startCheckout(tester);

    expect(find.text('Procesando tu cambio'), findsOneWidget);
    expect(find.text('10,000.00 USDT'), findsOneWidget);
    expect(semanticsOf(tester, steps[0]), '${steps[0]}: en curso');
    expect(semanticsOf(tester, steps[1]), '${steps[1]}: pendiente');

    await tester.pump(const Duration(milliseconds: 900));
    expect(semanticsOf(tester, steps[0]), '${steps[0]}: listo');
    expect(semanticsOf(tester, steps[1]), '${steps[1]}: en curso');

    // "Atrás" del sistema no interrumpe el proceso.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Procesando tu cambio'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(semanticsOf(tester, steps[2]), '${steps[2]}: listo');

    await finishProcessing(tester);
    handle.dispose();
  });

  testWidgets('al terminar muestra el comprobante completo', (tester) async {
    await startCheckout(tester);
    await finishProcessing(tester);

    expect(find.text('Procesando tu cambio'), findsNothing);
    expect(find.text('¡Cambio exitoso!'), findsOneWidget);
    for (final text in [
      'Tu transacción se completó correctamente.',
      '16,502,300.00 ARS',
      'por 10,000.00 USDT',
      '1 USDT = 1,650.23 ARS',
      'El Dorado',
      '14/11/2026',
      '9:24',
      'Completada',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(
      find.textContaining(SimulatedTransactionRepository.idPattern),
      findsOneWidget,
    );
  });

  testWidgets('"Volver al inicio" y "atrás" regresan a la calculadora', (
    tester,
  ) async {
    await startCheckout(tester);
    await finishProcessing(tester);

    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar'), findsOneWidget);
    expect(find.text('¡Cambio exitoso!'), findsNothing);

    // El procesamiento no queda en la pila: "atrás" no vuelve a él.
    await tester.tap(find.text('Iniciar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await finishProcessing(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Iniciar'), findsOneWidget);
  });

  testWidgets('copia el ID de la transacción', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await startCheckout(tester);
    await finishProcessing(tester);

    await tester.tap(find.byTooltip('Copiar ID'));
    await tester.pump();

    expect(copied, matches(SimulatedTransactionRepository.idPattern));
    expect(find.text(copied!), findsOneWidget);
    expect(find.text('ID copiado'), findsOneWidget);
  });

  testWidgets('si falla, muestra el error y "Reintentar" vuelve a procesar', (
    tester,
  ) async {
    final repository = _FailingOnceRepository();
    await startCheckout(tester, submitExchange: SubmitExchange(repository));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('No pudimos completar el cambio'), findsOneWidget);
    expect(find.text('Sin conexión. Revisa tu internet.'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Procesando tu cambio'), findsOneWidget);

    await finishProcessing(tester);
    expect(find.text('¡Cambio exitoso!'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('desde el error, "Volver" regresa a la calculadora', (
    tester,
  ) async {
    await startCheckout(
      tester,
      submitExchange: SubmitExchange(_FailingOnceRepository()),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar'), findsOneWidget);
  });

  group('ProcessingSteps.statusOf', () {
    ProcessingStepStatus at(int index, double t, {bool completed = false}) =>
        ProcessingSteps.statusOf(
          index,
          count: 3,
          t: t,
          completed: completed,
        );

    test('avanza un paso por tercio', () {
      expect(at(0, 0), ProcessingStepStatus.active);
      expect(at(1, 0), ProcessingStepStatus.pending);
      expect(at(0, 0.4), ProcessingStepStatus.done);
      expect(at(1, 0.4), ProcessingStepStatus.active);
      expect(at(2, 0.7), ProcessingStepStatus.active);
    });

    test('el último paso solo se completa con la respuesta', () {
      expect(at(2, 1), ProcessingStepStatus.active);
      expect(at(2, 1, completed: true), ProcessingStepStatus.done);
      expect(at(0, 0, completed: true), ProcessingStepStatus.done);
    });
  });
}

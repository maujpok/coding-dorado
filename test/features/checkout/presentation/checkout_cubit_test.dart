import 'package:bloc_test/bloc_test.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_quotes.dart';

/// Devuelve los resultados programados en orden.
class _ScriptedRepository implements TransactionRepository {
  _ScriptedRepository(this.results);

  final List<Result<ExchangeTransaction>> results;
  int calls = 0;

  @override
  Future<Result<ExchangeTransaction>> submit(ExchangeQuote quote) async =>
      results[calls++];
}

void main() {
  final quote = usdtToArsQuote();
  final transaction = ExchangeTransaction(
    id: 'TX-TEST-0001',
    quote: quote,
    completedAt: DateTime(2026, 11, 14, 9, 24),
  );

  CheckoutCubit build(
    _ScriptedRepository repository, {
    Duration minDuration = Duration.zero,
  }) => CheckoutCubit(
    submitExchange: SubmitExchange(repository),
    quote: quote,
    minDuration: minDuration,
  );

  test('arranca procesando', () {
    final cubit = build(_ScriptedRepository([]));
    expect(cubit.state, const CheckoutProcessing());
    cubit.close().ignore();
  });

  blocTest<CheckoutCubit, CheckoutState>(
    'éxito: emite la transacción',
    build: () => build(_ScriptedRepository([Ok(transaction)])),
    act: (cubit) => cubit.submit(),
    expect: () => [CheckoutSucceeded(transaction, attempt: 1)],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'falla y "Reintentar" vuelve a procesar con un intento nuevo',
    build: () => build(
      _ScriptedRepository([
        const Err(NetworkFailure()),
        Ok(transaction),
      ]),
    ),
    act: (cubit) async {
      await cubit.submit();
      await cubit.submit();
    },
    expect: () => [
      const CheckoutFailed(NetworkFailure(), attempt: 1),
      const CheckoutProcessing(attempt: 2),
      CheckoutSucceeded(transaction, attempt: 2),
    ],
  );

  test('ignora un segundo submit en curso y uno después del éxito', () async {
    final repository = _ScriptedRepository([Ok(transaction), Ok(transaction)]);
    final cubit = build(repository);

    await Future.wait([cubit.submit(), cubit.submit()]);
    await cubit.submit();

    expect(repository.calls, 1);
    await cubit.close();
  });

  test('dura al menos minDuration aunque la respuesta sea inmediata', () async {
    final cubit = build(
      _ScriptedRepository([Ok(transaction)]),
      minDuration: const Duration(milliseconds: 60),
    );
    final watch = Stopwatch()..start();

    await cubit.submit();

    expect(
      watch.elapsed,
      greaterThanOrEqualTo(const Duration(milliseconds: 60)),
    );
    expect(cubit.state, isA<CheckoutSucceeded>());
    await cubit.close();
  });
}

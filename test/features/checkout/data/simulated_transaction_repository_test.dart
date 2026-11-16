import 'dart:math';

import 'package:coding_dorado/features/checkout/data/simulated_transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_quotes.dart';

void main() {
  final completedAt = DateTime(2026, 11, 14, 9, 24);

  SimulatedTransactionRepository repository({Random? random}) =>
      SimulatedTransactionRepository(
        latency: Duration.zero,
        clock: () => completedAt,
        random: random,
      );

  test(
    'aprueba el cambio con la cotización, la hora del reloj y un ID',
    () async {
      final quote = usdtToArsQuote();

      final transaction = (await repository().submit(quote)).valueOrNull!;

      expect(transaction.quote, quote);
      expect(transaction.completedAt, completedAt);
      expect(
        transaction.id,
        matches(SimulatedTransactionRepository.idPattern),
      );
    },
  );

  test('con la misma semilla el ID se repite; sin semilla, no', () async {
    final quote = usdtToArsQuote();

    final a = await repository(random: Random(7)).submit(quote);
    final b = await repository(random: Random(7)).submit(quote);
    final ids = {
      for (var i = 0; i < 50; i++)
        (await repository().submit(quote)).valueOrNull!.id,
    };

    expect(a.valueOrNull!.id, b.valueOrNull!.id);
    expect(ids, hasLength(50));
  });

  test('el ID no usa caracteres ambiguos', () async {
    final quote = usdtToArsQuote();
    final source = repository(random: Random(1));
    for (var i = 0; i < 200; i++) {
      final id = (await source.submit(quote)).valueOrNull!.id;
      expect(id.substring(3), isNot(matches(RegExp('[ILOU]'))));
    }
  });
}

import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_quotes.dart';

class _RecordingRepository implements TransactionRepository {
  final List<ExchangeQuote> submitted = [];

  @override
  Future<Result<ExchangeTransaction>> submit(ExchangeQuote quote) async {
    submitted.add(quote);
    return Ok(
      ExchangeTransaction(
        id: 'TX-TEST-0001',
        quote: quote,
        completedAt: DateTime(2026, 11, 14),
      ),
    );
  }
}

void main() {
  test('delega en el repositorio', () async {
    final repository = _RecordingRepository();
    final quote = usdtToArsQuote();

    final result = await SubmitExchange(repository)(quote);

    expect(result.valueOrNull?.id, 'TX-TEST-0001');
    expect(repository.submitted, [quote]);
  });

  test('una cotización sin monto a recibir no se ejecuta', () async {
    final repository = _RecordingRepository();

    final result = await SubmitExchange(
      repository,
    )(usdtToArsQuote(receive: '0'));

    expect(result, const Err<ExchangeTransaction>(InvalidRateFailure()));
    expect(repository.submitted, isEmpty);
  });
}

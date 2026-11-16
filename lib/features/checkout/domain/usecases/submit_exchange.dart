import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:decimal/decimal.dart';

/// Ejecuta el cambio de una cotización confirmada.
final class SubmitExchange {
  const SubmitExchange(this._repository);

  final TransactionRepository _repository;

  Future<Result<ExchangeTransaction>> call(ExchangeQuote quote) async {
    if (quote.amount <= Decimal.zero || quote.receiveAmount <= Decimal.zero) {
      return const Err(InvalidRateFailure());
    }
    return _repository.submit(quote);
  }
}

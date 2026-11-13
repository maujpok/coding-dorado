import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:decimal/decimal.dart';

/// Calcula cuánto recibe el usuario con la tasa de una fuente.
///
/// - crypto→fiat: `monto × tasa`.
/// - fiat→crypto: `monto ÷ tasa`, con 8 decimales.
/// - Tasa ≤ 0 → [InvalidRateFailure].
/// - Monto bajo el mínimo de la fuente → [BelowMinimumFailure].
final class GetExchangeQuote {
  const GetExchangeQuote(this._repository);

  static const divisionScale = 8;

  final ExchangeRepository _repository;

  RateProvider get provider => _repository.provider;

  Future<Result<ExchangeQuote>> call(
    ExchangePair pair,
    Decimal amount, {
    bool forceRefresh = false,
  }) async {
    final result = await _repository.getRate(
      pair: pair,
      amount: amount,
      forceRefresh: forceRefresh,
    );
    return switch (result) {
      Err(:final failure) => Err(failure),
      Ok(value: final rate) => _quote(pair, amount, rate),
    };
  }

  Result<ExchangeQuote> _quote(
    ExchangePair pair,
    Decimal amount,
    ExchangeRate rate,
  ) {
    if (rate.fiatPerCrypto <= Decimal.zero) {
      return const Err(InvalidRateFailure());
    }
    final minAmount = rate.minAmount;
    if (minAmount != null && amount < minAmount) {
      return Err(BelowMinimumFailure(minAmount));
    }
    final receiveAmount = switch (pair.direction) {
      ExchangeDirection.cryptoToFiat => amount * rate.fiatPerCrypto,
      ExchangeDirection.fiatToCrypto => (amount / rate.fiatPerCrypto).toDecimal(
        scaleOnInfinitePrecision: divisionScale,
      ),
    };
    return Ok(
      ExchangeQuote(
        provider: provider,
        pair: pair,
        amount: amount,
        rate: rate,
        receiveAmount: receiveAmount,
      ),
    );
  }
}

import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:coding_dorado/features/quote_comparison/domain/entities/quote_comparison.dart';
import 'package:decimal/decimal.dart';

/// Cotiza el mismo par y monto con todos los proveedores, en paralelo, y
/// elige el que entrega más.
///
/// Un proveedor que falla no bloquea a los demás: su resultado queda como
/// `Err`. Usa los mismos `GetExchangeQuote` (y cachés) que las pestañas, así
/// que los números coinciden con los de cada calculadora.
final class CompareQuotes {
  CompareQuotes(Map<RateProvider, GetExchangeQuote> quoters)
    : _quoters = Map.unmodifiable(quoters);

  static final Decimal _hundred = Decimal.fromInt(100);

  final Map<RateProvider, GetExchangeQuote> _quoters;

  Iterable<RateProvider> get providers => _quoters.keys;

  Future<QuoteComparison> call(
    ExchangePair pair,
    Decimal amount, {
    bool forceRefresh = false,
  }) async {
    final providers = _quoters.keys.toList();
    final outcomes = await Future.wait([
      for (final provider in providers)
        _quoters[provider]!(pair, amount, forceRefresh: forceRefresh),
    ]);
    final results = <RateProvider, Result<ExchangeQuote>>{
      for (final (index, provider) in providers.indexed)
        provider: outcomes[index],
    };

    final ranked = [
      for (final outcome in outcomes) ?outcome.valueOrNull,
    ]..sort((a, b) => b.receiveAmount.compareTo(a.receiveAmount));

    if (ranked.isEmpty) {
      return QuoteComparison(pair: pair, amount: amount, results: results);
    }
    if (ranked.length == 1) {
      return QuoteComparison(
        pair: pair,
        amount: amount,
        results: results,
        best: ranked.first.provider,
      );
    }

    final first = ranked[0].receiveAmount;
    final second = ranked[1].receiveAmount;
    final difference = first - second;
    final percent = second > Decimal.zero
        ? (difference / second).toDecimal(
                scaleOnInfinitePrecision: GetExchangeQuote.divisionScale,
              ) *
              _hundred
        : null;

    return QuoteComparison(
      pair: pair,
      amount: amount,
      results: results,
      best: difference > Decimal.zero ? ranked.first.provider : null,
      difference: difference,
      differencePercent: percent,
    );
  }
}

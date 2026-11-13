import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Cotización: cuánto recibe el usuario por un monto, según una fuente.
final class ExchangeQuote extends Equatable {
  const ExchangeQuote({
    required this.provider,
    required this.pair,
    required this.amount,
    required this.rate,
    required this.receiveAmount,
  });

  final RateProvider provider;
  final ExchangePair pair;

  /// En la moneda `pair.from`.
  final Decimal amount;

  final ExchangeRate rate;

  /// En la moneda `pair.to`, con hasta 8 decimales; se trunca al mostrarlo.
  final Decimal receiveAmount;

  @override
  List<Object?> get props => [provider, pair, amount, rate, receiveAmount];
}

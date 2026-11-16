import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:equatable/equatable.dart';

/// Un cambio ejecutado: la cotización confirmada, su identificador y cuándo
/// se completó.
final class ExchangeTransaction extends Equatable {
  const ExchangeTransaction({
    required this.id,
    required this.quote,
    required this.completedAt,
  });

  final String id;
  final ExchangeQuote quote;
  final DateTime completedAt;

  @override
  List<Object?> get props => [id, quote, completedAt];
}

import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Cotizaciones de todos los proveedores para el mismo par y monto.
final class QuoteComparison extends Equatable {
  const QuoteComparison({
    required this.pair,
    required this.amount,
    required this.results,
    this.best,
    this.difference,
    this.differencePercent,
  });

  final ExchangePair pair;
  final Decimal amount;

  /// Un resultado por proveedor, en el orden de las pestañas.
  final Map<RateProvider, Result<ExchangeQuote>> results;

  /// El que entrega más de la moneda QUIERO. `null` si ninguno cotiza o si
  /// hay empate en el primer puesto.
  final RateProvider? best;

  /// Lo que se recibe de más con el mejor frente al segundo, en la moneda
  /// QUIERO. Solo existe con al menos dos cotizaciones; 0 si empatan.
  final Decimal? difference;

  /// [difference] como porcentaje del segundo (1.0 = 1 %).
  final Decimal? differencePercent;

  List<ExchangeQuote> get quotes => [
    for (final result in results.values) ?result.valueOrNull,
  ];

  /// Hay dos o más cotizaciones y las mejores son iguales.
  bool get isTie => best == null && difference == Decimal.zero;

  @override
  List<Object?> get props => [
    pair,
    amount,
    results,
    best,
    difference,
    differencePercent,
  ];
}

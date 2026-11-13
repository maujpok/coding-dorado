import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Tasa que entrega una fuente para un par y una dirección.
final class ExchangeRate extends Equatable {
  const ExchangeRate({
    required this.fiatPerCrypto,
    this.minAmount,
    this.estimatedTime,
    this.sampleSize,
  });

  /// Unidades de fiat por 1 crypto.
  final Decimal fiatPerCrypto;

  /// Mínimo en la moneda de TENGO; `null` si la fuente no lo informa.
  final Decimal? minAmount;

  /// `null` si la fuente no lo informa (la UI oculta la fila).
  final Duration? estimatedTime;

  /// Cuántas ofertas entraron en el cálculo (CriptoYa: exchanges en la
  /// mediana).
  final int? sampleSize;

  @override
  List<Object?> get props => [
    fiatPerCrypto,
    minAmount,
    estimatedTime,
    sampleSize,
  ];
}

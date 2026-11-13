import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Tasa tal como la entrega un data source, antes de pasar al dominio.
final class ExchangeRateModel extends Equatable {
  const ExchangeRateModel({
    required this.rate,
    this.minAmount,
    this.estimatedTime,
    this.sampleSize,
  });

  /// Fiat por 1 crypto.
  final Decimal rate;
  final Decimal? minAmount;
  final Duration? estimatedTime;
  final int? sampleSize;

  ExchangeRate toEntity() => ExchangeRate(
    fiatPerCrypto: rate,
    minAmount: minAmount,
    estimatedTime: estimatedTime,
    sampleSize: sampleSize,
  );

  @override
  List<Object?> get props => [rate, minAmount, estimatedTime, sampleSize];
}

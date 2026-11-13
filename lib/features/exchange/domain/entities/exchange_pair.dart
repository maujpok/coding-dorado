import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:equatable/equatable.dart';

enum ExchangeDirection {
  /// TENGO crypto, QUIERO fiat (vender crypto).
  cryptoToFiat,

  /// TENGO fiat, QUIERO crypto (comprar crypto).
  fiatToCrypto,
}

/// Par de cambio. Invariante: un lado es crypto y el otro fiat.
final class ExchangePair extends Equatable {
  ExchangePair({required this.from, required this.to}) {
    if (from.type == to.type) {
      throw ArgumentError(
        'Un par combina una crypto y una fiat; se recibió $from → $to.',
      );
    }
  }

  /// TENGO: la moneda del monto ingresado.
  final Currency from;

  /// QUIERO.
  final Currency to;

  ExchangeDirection get direction => from.isCrypto
      ? ExchangeDirection.cryptoToFiat
      : ExchangeDirection.fiatToCrypto;

  Currency get crypto => from.isCrypto ? from : to;
  Currency get fiat => from.isFiat ? from : to;

  ExchangePair swapped() => ExchangePair(from: to, to: from);

  ExchangePair withFrom(Currency currency) =>
      ExchangePair(from: currency, to: to);

  ExchangePair withTo(Currency currency) =>
      ExchangePair(from: from, to: currency);

  @override
  List<Object?> get props => [from, to];

  @override
  String toString() => '$from → $to';
}

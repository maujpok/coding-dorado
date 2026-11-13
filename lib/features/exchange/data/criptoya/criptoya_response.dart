import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/json_values.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Precios de un exchange para un par. `ask`: el usuario compra crypto;
/// `bid`: el usuario vende crypto. Los `total*` incluyen comisiones.
final class CriptoYaQuote extends Equatable {
  const CriptoYaQuote({required this.totalAsk, required this.totalBid});

  final Decimal totalAsk;
  final Decimal totalBid;

  /// Fiat por 1 crypto en la dirección del usuario.
  Decimal priceFor(ExchangeDirection direction) => switch (direction) {
    ExchangeDirection.cryptoToFiat => totalBid,
    ExchangeDirection.fiatToCrypto => totalAsk,
  };

  @override
  List<Object?> get props => [totalAsk, totalBid];
}

/// Respuesta de `GET /api/{coin}/{fiat}/{volumen}`:
/// `{ "binancep2p": { "ask": …, "totalAsk": …, "bid": …, "totalBid": … } }`.
final class CriptoYaResponse extends Equatable {
  const CriptoYaResponse(this.exchanges);

  /// Ignora las entradas que no tienen la forma esperada. Si la raíz no es un
  /// objeto, lanza [ParsingException].
  factory CriptoYaResponse.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingException('La respuesta de CriptoYa no es un objeto.');
    }
    return CriptoYaResponse({
      for (final MapEntry(:key, :value) in json.entries)
        key: ?_parseQuote(value),
    });
  }

  final Map<String, CriptoYaQuote> exchanges;

  /// Precios mayores que cero en la dirección pedida. Un 0 significa que el
  /// exchange no tiene ofertas.
  List<Decimal> pricesFor(ExchangeDirection direction) => [
    for (final quote in exchanges.values)
      if (quote.priceFor(direction) > Decimal.zero) quote.priceFor(direction),
  ];

  static CriptoYaQuote? _parseQuote(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final totalAsk = parseDecimal(raw['totalAsk'] ?? raw['ask']);
    final totalBid = parseDecimal(raw['totalBid'] ?? raw['bid']);
    if (totalAsk == null || totalBid == null) return null;
    return CriptoYaQuote(totalAsk: totalAsk, totalBid: totalBid);
  }

  @override
  List<Object?> get props => [exchanges];
}

/// Mediana; con una cantidad par de valores, el promedio de los centrales.
Decimal median(List<Decimal> values) {
  if (values.isEmpty) throw ArgumentError('median() necesita valores.');
  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];
  return ((sorted[middle - 1] + sorted[middle]) / Decimal.fromInt(2)).toDecimal(
    scaleOnInfinitePrecision: 8,
  );
}

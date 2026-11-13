import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/json_values.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Oferta recomendada (`data.byPrice`) del API de órdenes de El Dorado.
final class RecommendedOffer extends Equatable {
  const RecommendedOffer({
    required this.fiatToCryptoExchangeRate,
    this.cryptoMin,
    this.fiatMin,
    this.marketMakerOrderTime,
  });

  /// Fiat por 1 crypto.
  final Decimal fiatToCryptoExchangeRate;
  final Decimal? cryptoMin;
  final Decimal? fiatMin;

  /// Minutos promedio que tarda el maker en completar una orden.
  final Decimal? marketMakerOrderTime;

  @override
  List<Object?> get props => [
    fiatToCryptoExchangeRate,
    cryptoMin,
    fiatMin,
    marketMakerOrderTime,
  ];
}

/// Respuesta de `GET …/orderbook/public/recommendations`, según la forma
/// documentada (API_RESEARCH.md §2):
///
/// - HTTP siempre 200.
/// - `{"data": {"byPrice": Offer, "byReputation": Offer}}` con ofertas.
/// - `{"data": {}}` sin liquidez o monto fuera de límites:
///   [NoOffersException].
/// - `{"error": {"code": …, "message": …}}` → [ApiErrorException].
/// - La tasa llega como string.
abstract final class RecommendationResponse {
  static RecommendedOffer parse(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingException(
        'La respuesta de recommendations no es un objeto.',
      );
    }
    if (json['error'] case final Map<String, dynamic> error) {
      throw ApiErrorException(
        '${error['message'] ?? 'Error del API de órdenes.'}',
        code: error['code'] is String ? error['code'] as String : null,
      );
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParsingException('La respuesta no trae "data".');
    }
    final offer = data['byPrice'];
    if (offer == null) {
      throw const NoOffersException('El API de órdenes no tiene ofertas.');
    }
    if (offer is! Map<String, dynamic>) {
      throw const ParsingException('"byPrice" no es un objeto.');
    }
    final rate = parseDecimal(offer['fiatToCryptoExchangeRate']);
    if (rate == null) {
      throw const ParsingException('La oferta no trae una tasa válida.');
    }
    final limits = offer['limits'];
    return RecommendedOffer(
      fiatToCryptoExchangeRate: rate,
      cryptoMin: switch (limits) {
        {'crypto': {'minLimit': final Object? min}} => parseDecimal(min),
        _ => null,
      },
      fiatMin: switch (limits) {
        {'fiat': {'minLimit': final Object? min}} => parseDecimal(min),
        _ => null,
      },
      marketMakerOrderTime: switch (offer['offerMakerStats']) {
        {'marketMakerOrderTime': final Object? minutes} => parseDecimal(
          minutes,
        ),
        _ => null,
      },
    );
  }
}

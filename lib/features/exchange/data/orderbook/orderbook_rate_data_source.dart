import 'package:coding_dorado/core/cache/ttl_cache.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_model.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_currency_ids.dart';
import 'package:coding_dorado/features/exchange/data/orderbook/recommendation_response.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

/// `GET {API_URL}` (el endpoint `orderbook/public/recommendations` del
/// enunciado). A diferencia de `/api/prices`, devuelve una oferta concreta
/// cuya tasa depende del monto, con el tiempo estimado del maker.
final class OrderbookRateDataSource implements ExchangeRateDataSource {
  OrderbookRateDataSource(
    this._dio, {
    required this.endpoint,
    TtlCache<String, RecommendedOffer>? cache,
  }) : _cache = cache ?? TtlCache(ttl: cacheTtl);

  static const cacheTtl = Duration(seconds: 30);

  /// URL completa del endpoint.
  final String endpoint;
  final Dio _dio;
  final TtlCache<String, RecommendedOffer> _cache;

  /// `type`: 0 crypto→fiat, 1 fiat→crypto. El monto va en la moneda de
  /// TENGO (`amountCurrencyId`).
  static Map<String, Object> queryFor(ExchangePair pair, Decimal amount) => {
    'type': pair.direction == ExchangeDirection.cryptoToFiat ? 0 : 1,
    'cryptoCurrencyId': EldoradoCurrencyIds.of(pair.crypto),
    'fiatCurrencyId': EldoradoCurrencyIds.of(pair.fiat),
    'amount': amount.toString(),
    'amountCurrencyId': EldoradoCurrencyIds.of(pair.from),
  };

  @override
  Future<ExchangeRateModel> fetchRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  }) async {
    final query = queryFor(pair, amount);
    final offer = await _cache.get(query.toString(), () async {
      final response = await _dio.get<Object?>(
        endpoint,
        queryParameters: query,
      );
      return RecommendationResponse.parse(response.data);
    }, forceRefresh: forceRefresh);

    final minutes = offer.marketMakerOrderTime;
    return ExchangeRateModel(
      rate: offer.fiatToCryptoExchangeRate,
      minAmount: pair.from.isCrypto ? offer.cryptoMin : offer.fiatMin,
      estimatedTime: minutes == null
          ? null
          : Duration(minutes: minutes.ceil().toBigInt().toInt()),
    );
  }

  /// El API de órdenes no publica qué pares cotiza.
  @override
  Future<PairAvailability> availability() async =>
      const PairAvailability.unknown();
}

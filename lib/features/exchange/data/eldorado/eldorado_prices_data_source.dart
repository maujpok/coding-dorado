import 'package:coding_dorado/core/cache/ttl_cache.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_model.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/prices_response.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

/// `GET {ELDORADO_API_URL}/prices`: una sola respuesta con todas las fiat en
/// ambas direcciones, en fiat por 1 USDT. Se cachea 60 s.
final class EldoradoPricesDataSource implements ExchangeRateDataSource {
  EldoradoPricesDataSource(this._dio, {TtlCache<String, PricesResponse>? cache})
    : _cache = cache ?? TtlCache(ttl: cacheTtl);

  static const path = '/prices';
  static const cacheTtl = Duration(seconds: 60);

  /// `/prices` no informa el tiempo; se usa el valor del diseño.
  static const estimatedTime = Duration(minutes: 10);

  /// La única crypto que cotiza `/prices`.
  static const quotedCrypto = 'USDT';

  static const _cacheKey = 'prices';

  final Dio _dio;
  final TtlCache<String, PricesResponse> _cache;

  @override
  Future<ExchangeRateModel> fetchRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  }) async {
    if (pair.crypto.code != quotedCrypto) {
      throw UnsupportedPairException(
        'El Dorado /prices solo cotiza $quotedCrypto (pedido: ${pair.crypto}).',
      );
    }
    final prices = await _prices(forceRefresh: forceRefresh);
    final entry = prices.entryFor(PriceSide.of(pair.direction), pair.fiat.code);
    return ExchangeRateModel(
      rate: entry.price,
      minAmount: entry.inMin,
      estimatedTime: estimatedTime,
    );
  }

  @override
  Future<PairAvailability> availability() async {
    final prices = await _prices();
    return PairAvailability.only({
      for (final side in PriceSide.values)
        for (final fiat in prices.fiatsFor(side))
          (cryptoCode: quotedCrypto, fiatCode: fiat, direction: side.direction),
    });
  }

  Future<PricesResponse> _prices({bool forceRefresh = false}) {
    return _cache.get(_cacheKey, () async {
      final response = await _dio.get<Object?>(path);
      return PricesResponse.fromJson(response.data);
    }, forceRefresh: forceRefresh);
  }
}

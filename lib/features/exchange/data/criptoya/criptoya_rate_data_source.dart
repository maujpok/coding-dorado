import 'package:coding_dorado/core/cache/ttl_cache.dart';
import 'package:coding_dorado/features/exchange/data/common/data_exceptions.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_model.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_response.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

/// `GET {CRIPTOYA_API_URL}/{coin}/{fiat}/1`. La tasa es la mediana de los
/// exchanges con ofertas: `totalBid` al vender y `totalAsk` al comprar.
/// Se cachea 30 s por par, como indica su `cache-control`.
final class CriptoYaRateDataSource implements ExchangeRateDataSource {
  CriptoYaRateDataSource(
    this._dio, {
    TtlCache<String, CriptoYaResponse>? cache,
  }) : _cache = cache ?? TtlCache(ttl: cacheTtl);

  static const cacheTtl = Duration(seconds: 30);

  /// Se pide el precio por 1 unidad: la tasa no depende del monto.
  static const volume = 1;

  final Dio _dio;
  final TtlCache<String, CriptoYaResponse> _cache;

  static String pathFor(ExchangePair pair) =>
      '/${pair.crypto.code.toLowerCase()}'
      '/${pair.fiat.code.toLowerCase()}/$volume';

  @override
  Future<ExchangeRateModel> fetchRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  }) async {
    final path = pathFor(pair);
    final response = await _cache.get(
      path,
      () => _fetch(path),
      forceRefresh: forceRefresh,
    );
    final prices = response.pricesFor(pair.direction);
    if (prices.isEmpty) {
      throw NoOffersException('CriptoYa no tiene ofertas para $pair.');
    }
    return ExchangeRateModel(rate: median(prices), sampleSize: prices.length);
  }

  /// CriptoYa no publica la lista de pares: la falta de ofertas se informa
  /// al cotizar.
  @override
  Future<PairAvailability> availability() async =>
      const PairAvailability.unknown();

  Future<CriptoYaResponse> _fetch(String path) async {
    try {
      final response = await _dio.get<Object?>(path);
      return CriptoYaResponse.fromJson(response.data);
    } on DioException catch (error) {
      // Par desconocido: 404 con {"error": "Invalid pair"}.
      if (error.response?.statusCode == 404) {
        throw UnsupportedPairException('CriptoYa no reconoce $path.');
      }
      rethrow;
    }
  }
}

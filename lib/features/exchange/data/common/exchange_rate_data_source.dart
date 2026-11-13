import 'package:coding_dorado/features/exchange/data/common/exchange_rate_model.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:decimal/decimal.dart';

/// Fuente concreta de tasas (un API).
abstract interface class ExchangeRateDataSource {
  /// Lanza una `ExchangeDataException` o una `DioException`; el repositorio
  /// las traduce a `Failure`.
  Future<ExchangeRateModel> fetchRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  });

  /// Pares que la fuente cotiza, si los conoce de antemano.
  Future<PairAvailability> availability();
}

import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:decimal/decimal.dart';

/// Fuente de tasas. Hay una implementación por [RateProvider].
abstract interface class ExchangeRepository {
  RateProvider get provider;

  /// [amount] no lo usan las fuentes actuales (su tasa es por 1 crypto), pero
  /// sí el API de órdenes. [forceRefresh] ignora la caché.
  Future<Result<ExchangeRate>> getRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  });

  /// Nunca falla: ante un error devuelve [PairAvailability.unknown].
  Future<PairAvailability> getAvailability();
}

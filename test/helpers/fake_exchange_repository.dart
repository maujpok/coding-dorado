import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:decimal/decimal.dart';

typedef RateHandler =
    Future<Result<ExchangeRate>> Function(ExchangePair pair, Decimal amount);

/// Repositorio programable: cada prueba decide qué devuelve y cuándo.
class FakeExchangeRepository implements ExchangeRepository {
  FakeExchangeRepository({
    this.provider = RateProvider.eldorado,
    RateHandler? onGetRate,
    this.availability = const PairAvailability.unknown(),
  }) : onGetRate = onGetRate ?? _defaultHandler;

  static Future<Result<ExchangeRate>> _defaultHandler(
    ExchangePair pair,
    Decimal amount,
  ) async => Ok(ExchangeRate(fiatPerCrypto: Decimal.fromInt(25)));

  @override
  final RateProvider provider;

  RateHandler onGetRate;
  PairAvailability availability;

  final List<({ExchangePair pair, Decimal amount, bool forceRefresh})> calls =
      [];
  int availabilityCalls = 0;

  @override
  Future<Result<ExchangeRate>> getRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  }) {
    calls.add((pair: pair, amount: amount, forceRefresh: forceRefresh));
    return onGetRate(pair, amount);
  }

  @override
  Future<PairAvailability> getAvailability() async {
    availabilityCalls++;
    return availability;
  }
}

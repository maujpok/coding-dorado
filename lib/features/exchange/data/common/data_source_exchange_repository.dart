import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/common/map_data_exception.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/pair_availability.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:decimal/decimal.dart';

/// Repositorio respaldado por un data source. Concentra el mapeo de
/// excepciones a `Failure`, común a todos los proveedores.
abstract base class DataSourceExchangeRepository implements ExchangeRepository {
  DataSourceExchangeRepository(this.provider, this._dataSource);

  @override
  final RateProvider provider;

  final ExchangeRateDataSource _dataSource;

  @override
  Future<Result<ExchangeRate>> getRate({
    required ExchangePair pair,
    required Decimal amount,
    bool forceRefresh = false,
  }) async {
    try {
      final model = await _dataSource.fetchRate(
        pair: pair,
        amount: amount,
        forceRefresh: forceRefresh,
      );
      return Ok(model.toEntity());
    } on Exception catch (error) {
      return Err(mapDataException(error));
    }
  }

  @override
  Future<PairAvailability> getAvailability() async {
    try {
      return await _dataSource.availability();
    } on Exception {
      return const PairAvailability.unknown();
    }
  }
}

import 'package:coding_dorado/features/exchange/data/common/data_source_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';

/// Pestaña El Dorado. El data source es `/api/prices` o, en la Fase 10, el
/// API de órdenes.
final class EldoradoExchangeRepository extends DataSourceExchangeRepository {
  EldoradoExchangeRepository(ExchangeRateDataSource dataSource)
    : super(RateProvider.eldorado, dataSource);
}

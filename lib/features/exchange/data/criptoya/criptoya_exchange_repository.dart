import 'package:coding_dorado/features/exchange/data/common/data_source_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';

/// Pestaña CriptoYa.
final class CriptoYaExchangeRepository extends DataSourceExchangeRepository {
  CriptoYaExchangeRepository(ExchangeRateDataSource dataSource)
    : super(RateProvider.criptoya, dataSource);
}

import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/network/dio_factory.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/mock/mock_criptoya_interceptor.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_prices_data_source.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/mock/mock_eldorado_prices_interceptor.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Composition root: un cliente HTTP, un data source, un repositorio y un
/// `GetExchangeQuote` por [RateProvider]. Con `USE_MOCK=true`, cada cliente
/// lleva el interceptor mock de su proveedor.
void configureDependencies(GetIt getIt, AppConfig config) {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<ExchangeRepository>(
      EldoradoExchangeRepository(_eldoradoDataSource(config)),
      instanceName: RateProvider.eldorado.name,
    )
    ..registerSingleton<ExchangeRepository>(
      CriptoYaExchangeRepository(_criptoyaDataSource(config)),
      instanceName: RateProvider.criptoya.name,
    );

  for (final provider in RateProvider.values) {
    getIt.registerSingleton<GetExchangeQuote>(
      GetExchangeQuote(getIt.exchangeRepository(provider)),
      instanceName: provider.name,
    );
  }
}

extension ExchangeDependencies on GetIt {
  ExchangeRepository exchangeRepository(RateProvider provider) =>
      get<ExchangeRepository>(instanceName: provider.name);

  GetExchangeQuote getExchangeQuote(RateProvider provider) =>
      get<GetExchangeQuote>(instanceName: provider.name);

  Map<RateProvider, GetExchangeQuote> allQuoteUseCases() => {
    for (final provider in RateProvider.values)
      provider: getExchangeQuote(provider),
  };
}

ExchangeRateDataSource _eldoradoDataSource(AppConfig config) {
  final dio = createDio(
    baseUrl: config.eldoradoApiUrl,
    logRequests: kDebugMode && !config.useMock,
    interceptors: [
      if (config.useMock)
        MockEldoradoPricesInterceptor(
          scenario: EldoradoMockScenario.parse(config.mockScenarioEldorado),
          latency: config.mockLatency,
        ),
    ],
  );
  return EldoradoPricesDataSource(dio);
}

ExchangeRateDataSource _criptoyaDataSource(AppConfig config) {
  final dio = createDio(
    baseUrl: config.criptoyaApiUrl,
    logRequests: kDebugMode && !config.useMock,
    interceptors: [
      if (config.useMock)
        MockCriptoYaInterceptor(
          scenario: CriptoYaMockScenario.parse(config.mockScenarioCriptoya),
          latency: config.mockLatency,
        ),
    ],
  );
  return CriptoYaRateDataSource(dio);
}

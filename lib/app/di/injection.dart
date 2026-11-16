import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/core/network/dio_factory.dart';
import 'package:coding_dorado/features/checkout/data/simulated_transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/repositories/transaction_repository.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/exchange/data/common/exchange_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/criptoya/criptoya_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_exchange_repository.dart';
import 'package:coding_dorado/features/exchange/data/eldorado/eldorado_prices_data_source.dart';
import 'package:coding_dorado/features/exchange/data/orderbook/orderbook_rate_data_source.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/domain/repositories/exchange_repository.dart';
import 'package:coding_dorado/features/exchange/domain/usecases/get_exchange_quote.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// Composition root: un cliente HTTP, un data source, un repositorio y un
/// `GetExchangeQuote` por [RateProvider], `CompareQuotes` sobre todos y
/// `SubmitExchange` sobre la ejecución simulada.
///
/// [httpInterceptors] agrega interceptores al cliente HTTP de un proveedor,
/// antes del log (las pruebas responden ahí sin salir a la red).
void configureDependencies(
  GetIt getIt,
  AppConfig config, {
  Map<RateProvider, List<Interceptor>> httpInterceptors = const {},
}) {
  List<Interceptor> interceptorsOf(RateProvider provider) =>
      httpInterceptors[provider] ?? const [];
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<ExchangeRepository>(
      EldoradoExchangeRepository(
        _eldoradoDataSource(config, interceptorsOf(RateProvider.eldorado)),
      ),
      instanceName: RateProvider.eldorado.name,
    )
    ..registerSingleton<ExchangeRepository>(
      CriptoYaExchangeRepository(
        _criptoyaDataSource(config, interceptorsOf(RateProvider.criptoya)),
      ),
      instanceName: RateProvider.criptoya.name,
    );

  for (final provider in RateProvider.values) {
    getIt.registerSingleton<GetExchangeQuote>(
      GetExchangeQuote(getIt.exchangeRepository(provider)),
      instanceName: provider.name,
    );
  }
  getIt
    ..registerSingleton<CompareQuotes>(CompareQuotes(getIt.allQuoteUseCases()))
    // Ninguna API pública ejecuta cambios: siempre es simulado.
    ..registerSingleton<TransactionRepository>(
      SimulatedTransactionRepository(),
    )
    ..registerSingleton<SubmitExchange>(
      SubmitExchange(getIt<TransactionRepository>()),
    );
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

ExchangeRateDataSource _eldoradoDataSource(
  AppConfig config,
  List<Interceptor> interceptors,
) {
  if (config.eldoradoSource == EldoradoSource.orderbook) {
    if (config.orderbookApiUrl.isNotEmpty) {
      return OrderbookRateDataSource(
        createDio(
          baseUrl: '',
          logRequests: kDebugMode,
          interceptors: interceptors,
        ),
        endpoint: config.orderbookApiUrl,
      );
    }
    debugPrint(
      'ELDORADO_SOURCE=orderbook necesita API_URL; se usa /api/prices.',
    );
  }
  return EldoradoPricesDataSource(
    createDio(
      baseUrl: config.eldoradoApiUrl,
      logRequests: kDebugMode,
      interceptors: interceptors,
    ),
  );
}

ExchangeRateDataSource _criptoyaDataSource(
  AppConfig config,
  List<Interceptor> interceptors,
) => CriptoYaRateDataSource(
  createDio(
    baseUrl: config.criptoyaApiUrl,
    logRequests: kDebugMode,
    interceptors: interceptors,
  ),
);

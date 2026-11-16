import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/di/injection.dart';
import 'package:coding_dorado/core/config/app_config.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

/// Lee la configuración, arma las dependencias y arranca la app.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final getIt = GetIt.instance;
  configureDependencies(getIt, config);

  runApp(
    App(
      createExchangeBloc: (provider) => ExchangeBloc(
        getQuote: getIt.getExchangeQuote(provider),
        repository: getIt.exchangeRepository(provider),
      ),
      compareQuotes: getIt<CompareQuotes>(),
      submitExchange: getIt<SubmitExchange>(),
    ),
  );
}

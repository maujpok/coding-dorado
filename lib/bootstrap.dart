import 'package:coding_dorado/app/app.dart';
import 'package:coding_dorado/app/config_error_app.dart';
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
  runApp(rootApp(AppConfig.fromEnvironment(), GetIt.instance));
}

/// La app sobre las dependencias de [getIt]. Si falta configuración (se
/// ejecutó sin el `.env`), [ConfigErrorApp] lo explica en pantalla en lugar
/// de dejar la app en el splash.
Widget rootApp(AppConfig config, GetIt getIt) {
  final missing = config.missingKeys;
  if (missing.isNotEmpty) {
    debugPrint(MissingConfigException(missing).toString());
    return ConfigErrorApp(missingKeys: missing);
  }
  configureDependencies(getIt, config);
  return App(
    createExchangeBloc: (provider) => ExchangeBloc(
      getQuote: getIt.getExchangeQuote(provider),
      repository: getIt.exchangeRepository(provider),
    ),
    compareQuotes: getIt<CompareQuotes>(),
    submitExchange: getIt<SubmitExchange>(),
  );
}

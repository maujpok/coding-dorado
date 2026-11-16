import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/home/presentation/pages/home_page.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    required this.createExchangeBloc,
    required this.compareQuotes,
    required this.submitExchange,
    super.key,
  });

  final ExchangeBlocFactory createExchangeBloc;
  final CompareQuotes compareQuotes;
  final SubmitExchange submitExchange;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(
        createExchangeBloc: createExchangeBloc,
        compareQuotes: compareQuotes,
        submitExchange: submitExchange,
      ),
    );
  }
}

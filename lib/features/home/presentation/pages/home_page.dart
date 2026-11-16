import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/checkout/domain/usecases/submit_exchange.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_processing_page.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/views/exchange_view.dart';
import 'package:coding_dorado/features/home/presentation/cubit/home_cubit.dart';
import 'package:coding_dorado/features/home/presentation/widgets/provider_tabs.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:coding_dorado/features/quote_comparison/presentation/widgets/quote_comparison_sheet.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef ExchangeBlocFactory = ExchangeBloc Function(RateProvider provider);

/// Home con una pestaña por proveedor. Los `ExchangeBloc` viven acá (no en
/// cada pestaña) para que cada una conserve su estado al cambiar.
///
/// Hay dos blocs del mismo tipo, así que no se buscan por tipo en el árbol:
/// cada pestaña recibe el suyo con `BlocProvider.value`.
///
/// También compone las features: comparación de cotizaciones y ejecución
/// del cambio confirmado (`checkout`).
class HomePage extends StatefulWidget {
  const HomePage({
    required this.createExchangeBloc,
    required this.compareQuotes,
    required this.submitExchange,
    super.key,
  });

  final ExchangeBlocFactory createExchangeBloc;
  final CompareQuotes compareQuotes;
  final SubmitExchange submitExchange;

  /// Color del semicírculo de fondo de cada pestaña, para distinguirlas.
  static Color decorationColorOf(RateProvider provider, AppColors colors) =>
      switch (provider) {
        RateProvider.eldorado => colors.backgroundDecoration,
        RateProvider.criptoya => colors.backgroundDecorationSecondary,
      };

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeCubit _homeCubit = HomeCubit();
  late final Map<RateProvider, ExchangeBloc> _blocs = {
    for (final provider in RateProvider.values)
      provider: widget.createExchangeBloc(provider)
        ..add(const ExchangeStarted()),
  };

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Al volver a la app, cada pestaña recotiza si su caché venció.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        for (final bloc in _blocs.values) {
          bloc.add(const ExchangeAppResumed());
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    for (final bloc in _blocs.values) {
      bloc.close().ignore();
    }
    _homeCubit.close().ignore();
    super.dispose();
  }

  Future<void> _openComparison(ExchangePair pair, Decimal amount) async {
    final chosen = await showQuoteComparisonSheet(
      context: context,
      compareQuotes: widget.compareQuotes,
      pair: pair,
      amount: amount,
    );
    if (chosen != null) _openInProvider(chosen, pair, amount);
  }

  /// Cambia a la pestaña de [provider] con el mismo par y monto.
  void _openInProvider(
    RateProvider provider,
    ExchangePair pair,
    Decimal amount,
  ) {
    _homeCubit.select(provider);
    _blocs[provider]!.add(ExchangePrefilled(pair: pair, amount: amount));
  }

  /// Procesa el cambio confirmado en pantalla completa y muestra el
  /// comprobante. Si se completó, la calculadora de esa pestaña vuelve a
  /// empezar: al regresar del comprobante está lista para otro cambio.
  Future<void> _startCheckout(ExchangeQuote quote) async {
    final transaction = await Navigator.of(context).push(
      CheckoutProcessingPage.route(
        quote: quote,
        submitExchange: widget.submitExchange,
      ),
    );
    if (transaction != null) {
      _blocs[transaction.quote.provider]?.add(const ExchangeReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<HomeCubit, RateProvider>(
        builder: (context, active) {
          return Scaffold(
            body: GestureDetector(
              // Tocar fuera del campo cierra el teclado.
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: DsBackground(
                decorationColor: HomePage.decorationColorOf(
                  active,
                  context.colors,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppLayout.horizontalMargin(constraints.maxWidth),
                            AppSpacing.md,
                            AppLayout.horizontalMargin(constraints.maxWidth),
                            0,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppSizes.contentMaxWidth,
                            ),
                            child: ProviderTabs(
                              selected: active,
                              onChanged: _homeCubit.select,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              for (final provider in RateProvider.values)
                                _TabContent(
                                  active: provider == active,
                                  child: BlocProvider.value(
                                    value: _blocs[provider]!,
                                    child: ExchangeView(
                                      provider: provider,
                                      onCompare: _openComparison,
                                      onOpenInProvider: _openInProvider,
                                      onConfirmed: (quote) =>
                                          _startCheckout(quote).ignore(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Pestaña que conserva su estado aunque no esté visible y aparece con un
/// fundido. Las inactivas no reciben toques, no animan y no se leen.
class _TabContent extends StatelessWidget {
  const _TabContent({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: active ? 1 : 0,
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        child: IgnorePointer(
          ignoring: !active,
          child: ExcludeSemantics(
            excluding: !active,
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}

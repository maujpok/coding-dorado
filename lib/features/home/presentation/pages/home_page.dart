import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
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
class HomePage extends StatefulWidget {
  const HomePage({
    required this.createExchangeBloc,
    required this.compareQuotes,
    super.key,
  });

  final ExchangeBlocFactory createExchangeBloc;
  final CompareQuotes compareQuotes;

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

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<HomeCubit, RateProvider>(
        builder: (context, active) {
          return Scaffold(
            body: DsBackground(
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
                        child: IndexedStack(
                          index: RateProvider.values.indexOf(active),
                          children: [
                            for (final provider in RateProvider.values)
                              BlocProvider.value(
                                value: _blocs[provider]!,
                                child: ExchangeView(
                                  provider: provider,
                                  onCompare: _openComparison,
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
          );
        },
      ),
    );
  }
}

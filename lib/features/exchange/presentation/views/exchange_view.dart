import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_picker_sheet.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/exchange_card.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/source_caption.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// La calculadora de una pestaña. Lee su `ExchangeBloc` del árbol.
typedef PairAmountCallback = void Function(ExchangePair pair, Decimal amount);

class ExchangeView extends StatelessWidget {
  const ExchangeView({required this.provider, this.onCompare, super.key});

  final RateProvider provider;

  /// Abre la comparación con el par y el monto actuales. La provee quien
  /// compone la pantalla, así `exchange` no depende de `quote_comparison`.
  final PairAmountCallback? onCompare;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExchangeBloc, ExchangeState>(
      listenWhen: (previous, current) =>
          current.submissionCount > previous.submissionCount,
      listener: _showConfirmation,
      builder: (context, state) {
        final bloc = context.read<ExchangeBloc>();
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.horizontalMargin(
                        constraints.maxWidth,
                      ),
                      vertical: AppSpacing.xxl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.contentMaxWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExchangeCard(
                            provider: provider,
                            state: state,
                            onFromTap: () => _pickFrom(context, state),
                            onToTap: () => _pickTo(context, state),
                            onSwap: () =>
                                bloc.add(const ExchangeCurrenciesSwapped()),
                            onAmountChanged: (text) =>
                                bloc.add(ExchangeAmountChanged(text)),
                            onSubmit: () => bloc.add(const ExchangeSubmitted()),
                            onRetry: () =>
                                bloc.add(const ExchangeRatesRefreshed()),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SourceCaption(
                            provider: provider,
                            quote: state.quote.latestQuote,
                          ),
                          if (onCompare != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            DsLink(
                              label: AppLocalizations.of(
                                context,
                              ).compareAction,
                              icon: Icons.compare_arrows_rounded,
                              onPressed: switch (state.amount) {
                                final amount? => () => onCompare!(
                                  state.pair,
                                  amount,
                                ),
                                null => null,
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickFrom(BuildContext context, ExchangeState state) async {
    final bloc = context.read<ExchangeBloc>();
    final currency = await showCurrencyPicker(
      context: context,
      type: state.pair.from.type,
      selected: state.pair.from,
    );
    if (currency != null) bloc.add(ExchangeFromCurrencySelected(currency));
  }

  Future<void> _pickTo(BuildContext context, ExchangeState state) async {
    final bloc = context.read<ExchangeBloc>();
    final currency = await showCurrencyPicker(
      context: context,
      type: state.pair.to.type,
      selected: state.pair.to,
    );
    if (currency != null) bloc.add(ExchangeToCurrencySelected(currency));
  }

  void _showConfirmation(BuildContext context, ExchangeState state) {
    final quote = state.quote.latestQuote;
    if (quote == null) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.exchangeConfirmation(
              AmountFormatter.format(quote.amount),
              quote.pair.from.code,
              AmountFormatter.format(quote.receiveAmount, truncate: true),
              quote.pair.to.code,
            ),
          ),
        ),
      );
  }
}

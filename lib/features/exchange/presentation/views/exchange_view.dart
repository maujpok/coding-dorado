import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/views/currency_selection.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/exchange_card.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/exchange_confirmation_sheet.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_message.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/source_caption.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef PairAmountCallback = void Function(ExchangePair pair, Decimal amount);

typedef OpenInProviderCallback =
    void Function(RateProvider provider, ExchangePair pair, Decimal amount);

/// La calculadora de una pestaña. Lee su `ExchangeBloc` del árbol.
///
/// "Simular" abre la confirmación. Las acciones que salen de la calculadora
/// (comparar, "Ver en …", ejecutar el cambio confirmado) las provee quien
/// compone la pantalla, así `exchange` no depende de otras features.
class ExchangeView extends StatelessWidget {
  const ExchangeView({
    required this.provider,
    this.onCompare,
    this.onOpenInProvider,
    this.onConfirmed,
    super.key,
  });

  final RateProvider provider;

  /// Abre la comparación con el par y el monto actuales.
  final PairAmountCallback? onCompare;

  /// Lleva el par y el monto a la pestaña de otro proveedor.
  final OpenInProviderCallback? onOpenInProvider;

  /// El usuario confirmó el cambio con esta cotización.
  final ValueChanged<ExchangeQuote>? onConfirmed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeBloc, ExchangeState>(
      builder: (context, state) {
        final bloc = context.read<ExchangeBloc>();
        final l10n = AppLocalizations.of(context);
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                // Anclada arriba, no centrada: así queda en el mismo lugar en
                // ambas pestañas aunque sus tarjetas midan distinto.
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.horizontalMargin(constraints.maxWidth),
                      AppLayout.calculatorTopInset(constraints.maxHeight),
                      AppLayout.horizontalMargin(constraints.maxWidth),
                      AppSpacing.xxl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.contentMaxWidth,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Semantics(
                              header: true,
                              child: Text(
                                l10n.calculatorTitle,
                                style: AppTypography.display.copyWith(
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ExchangeCard(
                            provider: provider,
                            state: state,
                            onFromTap: () => selectFromCurrency(context),
                            onToTap: () => selectToCurrency(context),
                            onSwap: () =>
                                bloc.add(const ExchangeCurrenciesSwapped()),
                            onAmountChanged: (text) =>
                                bloc.add(ExchangeAmountChanged(text)),
                            onSubmit: () => _confirm(context),
                            onRetry: () =>
                                bloc.add(const ExchangeRatesRefreshed()),
                            messageActions: _messageActions(context, state),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SourceCaption(
                            provider: provider,
                            quote: state.quote.latestQuote,
                          ),
                          if (onCompare case final compare?) ...[
                            const SizedBox(height: AppSpacing.xs),
                            DsLink(
                              label: l10n.compareAction,
                              icon: Icons.compare_arrows_rounded,
                              onPressed: switch (state.amount) {
                                final amount? => () => compare(
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

  /// Acciones para "par no disponible" y "sin ofertas": elegir otra moneda
  /// o ver el mismo par en otra pestaña.
  List<QuoteMessageAction> _messageActions(
    BuildContext context,
    ExchangeState state,
  ) {
    final status = state.quote;
    if (status is! QuoteFailed) return const [];
    final failure = status.failure;
    if (failure is! PairUnavailableFailure && failure is! NoOffersFailure) {
      return const [];
    }
    final l10n = AppLocalizations.of(context);
    final amount = state.amount;
    final open = onOpenInProvider;
    return [
      if (failure is PairUnavailableFailure)
        QuoteMessageAction(
          label: l10n.chooseCurrencyAction,
          onPressed: () => selectUnavailableSide(context),
        ),
      if (amount != null && open != null)
        for (final other in RateProvider.values.where((p) => p != provider))
          QuoteMessageAction(
            label: l10n.viewInProviderAction(l10n.providerName(other)),
            onPressed: () => open(other, state.pair, amount),
          ),
    ];
  }

  Future<void> _confirm(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final quote = await showExchangeConfirmationSheet(
      context: context,
      bloc: context.read<ExchangeBloc>(),
      provider: provider,
    );
    if (quote != null) onConfirmed?.call(quote);
  }
}

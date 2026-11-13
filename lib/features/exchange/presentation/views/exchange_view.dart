import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_picker_sheet.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/exchange_card.dart';
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
/// Las acciones que cruzan pestañas (comparar, "Ver en …") las provee quien
/// compone la pantalla, así `exchange` no depende de `quote_comparison` ni
/// de `home`.
class ExchangeView extends StatelessWidget {
  const ExchangeView({
    required this.provider,
    this.onCompare,
    this.onOpenInProvider,
    super.key,
  });

  final RateProvider provider;

  /// Abre la comparación con el par y el monto actuales.
  final PairAmountCallback? onCompare;

  /// Lleva el par y el monto a la pestaña de otro proveedor.
  final OpenInProviderCallback? onOpenInProvider;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExchangeBloc, ExchangeState>(
      listenWhen: (previous, current) =>
          current.submissionCount > previous.submissionCount,
      listener: _showConfirmation,
      builder: (context, state) {
        final bloc = context.read<ExchangeBloc>();
        final l10n = AppLocalizations.of(context);
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
          onPressed: () => _pickUnavailableSide(context, state),
        ),
      if (amount != null && open != null)
        for (final other in RateProvider.values.where((p) => p != provider))
          QuoteMessageAction(
            label: l10n.viewInProviderAction(l10n.providerName(other)),
            onPressed: () => open(other, state.pair, amount),
          ),
    ];
  }

  /// Si la fuente no cotiza la crypto con ninguna fiat (USDC en El Dorado),
  /// el problema es la crypto; si no, la fiat.
  Future<void> _pickUnavailableSide(
    BuildContext context,
    ExchangeState state,
  ) {
    final pair = state.pair;
    final cryptoQuoted = CurrencyCatalog.fiats.any(
      (fiat) =>
          state.availability.isAvailable(
            ExchangePair(from: pair.crypto, to: fiat),
          ) ||
          state.availability.isAvailable(
            ExchangePair(from: fiat, to: pair.crypto),
          ),
    );
    final pickCryptoSide = !cryptoQuoted;
    final fromIsTarget = pickCryptoSide == pair.from.isCrypto;
    return fromIsTarget ? _pickFrom(context, state) : _pickTo(context, state);
  }

  Future<void> _pickFrom(BuildContext context, ExchangeState state) async {
    final bloc = context.read<ExchangeBloc>();
    final currency = await showCurrencyPicker(
      context: context,
      type: state.pair.from.type,
      selected: state.pair.from,
      isAvailable: (candidate) =>
          state.availability.isAvailable(state.pair.withFrom(candidate)),
    );
    if (currency != null) bloc.add(ExchangeFromCurrencySelected(currency));
  }

  Future<void> _pickTo(BuildContext context, ExchangeState state) async {
    final bloc = context.read<ExchangeBloc>();
    final currency = await showCurrencyPicker(
      context: context,
      type: state.pair.to.type,
      selected: state.pair.to,
      isAvailable: (candidate) =>
          state.availability.isAvailable(state.pair.withTo(candidate)),
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

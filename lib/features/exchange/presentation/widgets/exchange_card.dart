import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/l10n/exchange_l10n.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/amount_field.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_pair_selector.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_message.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_summary.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// La tarjeta del diseño: selector de par, monto, resumen y "Cambiar".
class ExchangeCard extends StatelessWidget {
  const ExchangeCard({
    required this.provider,
    required this.state,
    required this.onFromTap,
    required this.onToTap,
    required this.onSwap,
    required this.onAmountChanged,
    required this.onSubmit,
    required this.onRetry,
    this.messageActions = const [],
    super.key,
  });

  final RateProvider provider;
  final ExchangeState state;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSwap;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSubmit;
  final VoidCallback onRetry;

  /// Acciones extra para el mensaje de error (por ejemplo, "Ver en …").
  final List<QuoteMessageAction> messageActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = state.quote;
    final failure = status is QuoteFailed ? status.failure : null;

    return DsCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CurrencyPairSelector(
            pair: state.pair,
            onFromTap: onFromTap,
            onToTap: onToTap,
            onSwap: onSwap,
          ),
          const SizedBox(height: AppSpacing.md),
          AmountField(
            currency: state.pair.from,
            text: state.amountText,
            onChanged: onAmountChanged,
            hasError: failure is BelowMinimumFailure,
          ),
          // El mínimo se muestra junto al campo, que es lo que hay que
          // corregir; los demás errores van debajo del resumen.
          AnimatedSize(
            duration: AppMotion.normal,
            curve: AppMotion.curve,
            child: failure is BelowMinimumFailure
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.failureMessage(
                          failure,
                          provider: provider,
                          from: state.pair.from,
                        ),
                        style: AppTypography.caption.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: AppSpacing.xl),
          QuoteSummary(pair: state.pair, status: status),
          AnimatedSize(
            duration: AppMotion.normal,
            curve: AppMotion.curve,
            child: failure == null || failure is BelowMinimumFailure
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: QuoteMessage(
                      tone:
                          failure is PairUnavailableFailure ||
                              failure is NoOffersFailure
                          ? QuoteMessageTone.info
                          : QuoteMessageTone.error,
                      message: l10n.failureMessage(
                        failure,
                        provider: provider,
                        from: state.pair.from,
                      ),
                      actions: [
                        if (failure is! PairUnavailableFailure)
                          QuoteMessageAction(
                            label: l10n.retryAction,
                            onPressed: onRetry,
                          ),
                        ...messageActions,
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
          DsPrimaryButton(
            label: l10n.exchangeButton,
            onPressed: state.canSubmit ? onSubmit : null,
            isLoading: state.isSubmitting,
          ),
        ],
      ),
    );
  }
}

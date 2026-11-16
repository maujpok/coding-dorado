import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/amount_field.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_pair_selector.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Lo editable de la tarjeta: la píldora TENGO / QUIERO y el monto.
class ExchangeInputs extends StatelessWidget {
  const ExchangeInputs({
    required this.provider,
    required this.state,
    required this.onFromTap,
    required this.onToTap,
    required this.onSwap,
    required this.onAmountChanged,
    super.key,
  });

  final RateProvider provider;
  final ExchangeState state;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSwap;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        AmountInput(
          provider: provider,
          state: state,
          onChanged: onAmountChanged,
        ),
      ],
    );
  }
}

/// Campo del monto y, si no alcanza, el mínimo debajo: se muestra junto al
/// campo, que es lo que hay que corregir. Los demás errores van debajo del
/// resumen. Lo comparten la tarjeta y la confirmación.
class AmountInput extends StatelessWidget {
  const AmountInput({
    required this.provider,
    required this.state,
    required this.onChanged,
    super.key,
  });

  final RateProvider provider;
  final ExchangeState state;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = state.quote;
    final failure = status is QuoteFailed ? status.failure : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AmountField(
          currency: state.pair.from,
          text: state.amountText,
          onChanged: onChanged,
          hasError: failure is BelowMinimumFailure,
        ),
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
      ],
    );
  }
}

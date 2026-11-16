import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/exchange_inputs.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_failure_message.dart';
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
          ExchangeInputs(
            provider: provider,
            state: state,
            onFromTap: onFromTap,
            onToTap: onToTap,
            onSwap: onSwap,
            onAmountChanged: onAmountChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          QuoteSummary(pair: state.pair, status: state.quote),
          QuoteFailureMessage(
            provider: provider,
            state: state,
            onRetry: onRetry,
            actions: messageActions,
          ),
          const SizedBox(height: AppSpacing.xl),
          DsPrimaryButton(
            label: l10n.exchangeButton,
            onPressed: state.canSubmit ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}

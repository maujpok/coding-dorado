import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_message.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Mensaje para una cotización fallida, salvo el mínimo (va junto al campo).
/// Sin error no ocupa espacio; aparece y desaparece con una animación.
class QuoteFailureMessage extends StatelessWidget {
  const QuoteFailureMessage({
    required this.provider,
    required this.state,
    required this.onRetry,
    this.actions = const [],
    super.key,
  });

  final RateProvider provider;
  final ExchangeState state;
  final VoidCallback onRetry;

  /// Acciones extra (por ejemplo, "Ver en …").
  final List<QuoteMessageAction> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = state.quote;
    final failure = status is QuoteFailed ? status.failure : null;

    return AnimatedSize(
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
                  ...actions,
                ],
              ),
            ),
    );
  }
}

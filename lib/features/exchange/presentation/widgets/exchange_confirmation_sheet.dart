import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/views/currency_selection.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/confirmation_fields.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_failure_message.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/quote_summary.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abre la confirmación sobre el `ExchangeBloc` de la pestaña: lo que se
/// edite acá (monto, monedas) queda también en la calculadora.
///
/// Devuelve la cotización confirmada, o `null` si se cancela.
Future<ExchangeQuote?> showExchangeConfirmationSheet({
  required BuildContext context,
  required ExchangeBloc bloc,
  required RateProvider provider,
}) {
  final l10n = AppLocalizations.of(context);
  return showDsBottomSheet<ExchangeQuote>(
    context: context,
    title: l10n.confirmTitle,
    builder: (sheetContext) => BlocProvider.value(
      value: bloc,
      child: ExchangeConfirmationView(
        provider: provider,
        onConfirm: (quote) => Navigator.of(sheetContext).pop(quote),
        onCancel: () => Navigator.of(sheetContext).pop(),
      ),
    ),
  );
}

/// Contenido de la confirmación: lo editable en tres filas (moneda que
/// entregas, moneda que recibes, cantidad), el detalle de la cotización
/// vigente, "Confirmar" y "Cancelar".
class ExchangeConfirmationView extends StatelessWidget {
  const ExchangeConfirmationView({
    required this.provider,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final RateProvider provider;
  final ValueChanged<ExchangeQuote> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ExchangeBloc, ExchangeState>(
      builder: (context, state) {
        final bloc = context.read<ExchangeBloc>();
        // Solo se confirma la cotización del par y el monto actuales: si se
        // edita algo, "Confirmar" espera la nueva.
        final quote = state.currentQuote;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.confirmSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.message.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ConfirmationFields(
                provider: provider,
                state: state,
                onFromTap: () => selectFromCurrency(context),
                onToTap: () => selectToCurrency(context),
                onSwap: () => bloc.add(const ExchangeCurrenciesSwapped()),
                onAmountChanged: (text) =>
                    bloc.add(ExchangeAmountChanged(text)),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Details(provider: provider, state: state),
              QuoteFailureMessage(
                provider: provider,
                state: state,
                onRetry: () => bloc.add(const ExchangeRatesRefreshed()),
              ),
              const SizedBox(height: AppSpacing.xl),
              DsPrimaryButton(
                label: l10n.confirmAction,
                onPressed: quote == null ? null : () => onConfirm(quote),
                isLoading: state.quote is QuoteLoading,
              ),
              const SizedBox(height: AppSpacing.xs),
              DsTextButton(label: l10n.cancelAction, onPressed: onCancel),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.simulationNote,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tasa, recibirás, tiempo y fuente. Lo que se envía ya está en las filas
/// editables.
class _Details extends StatelessWidget {
  const _Details({required this.provider, required this.state});

  final RateProvider provider;
  final ExchangeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsCard(
      elevated: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          QuoteSummary(pair: state.pair, status: state.quote),
          QuoteRow(
            label: l10n.sourceLabel,
            value: l10n.providerName(provider),
            approximate: false,
          ),
        ],
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_avatar.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/exchange_inputs.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lo editable de la confirmación en tres filas: moneda que entregas,
/// moneda que recibes y cantidad. "Invertir" da vuelta el par.
class ConfirmationFields extends StatelessWidget {
  const ConfirmationFields({
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
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(l10n.confirmFromLabel),
        CurrencyField(
          label: l10n.confirmFromLabel,
          currency: state.pair.from,
          onTap: onFromTap,
        ),
        const SizedBox(height: AppSpacing.md),
        _FieldLabel(l10n.confirmToLabel, trailing: _SwapAction(onSwap)),
        CurrencyField(
          label: l10n.confirmToLabel,
          currency: state.pair.to,
          onTap: onToTap,
        ),
        const SizedBox(height: AppSpacing.md),
        _FieldLabel(l10n.confirmAmountLabel),
        AmountInput(
          provider: provider,
          state: state,
          onChanged: onAmountChanged,
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: ExcludeSemantics(
              child: Text(
                text,
                style: AppTypography.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// "⇅ Invertir": acción compacta junto a la etiqueta de la segunda fila.
class _SwapAction extends StatelessWidget {
  const _SwapAction(this.onPressed);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.swapSemantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick().ignore();
          onPressed();
        },
        borderRadius: BorderRadius.circular(AppRadius.badge),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swap_vert_rounded,
                size: AppSizes.iconSmall,
                color: colors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                l10n.swapAction,
                style: AppTypography.label.copyWith(
                  color: colors.textPrimary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de una moneda: ícono, código, nombre y chevron. Abre el selector.
class CurrencyField extends StatelessWidget {
  const CurrencyField({
    required this.label,
    required this.currency,
    required this.onTap,
    super.key,
  });

  /// Para accesibilidad: "Moneda que entregas: USDT. Cambiar moneda".
  final String label;
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppRadius.control);
    return Semantics(
      button: true,
      label: l10n.selectorSemantics(label, currency.code),
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: colors.fieldBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: AppSizes.fieldHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  CurrencyAvatar(
                    currency: currency,
                    size: AppSizes.currencyIconSmall,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    currency.code,
                    style: AppTypography.bodyStrong.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      currency.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AppSizes.iconMedium,
                    color: colors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

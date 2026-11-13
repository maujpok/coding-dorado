import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_avatar.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Píldora con TENGO / QUIERO sobre el borde y el botón de swap al centro.
class CurrencyPairSelector extends StatelessWidget {
  const CurrencyPairSelector({
    required this.pair,
    required this.onFromTap,
    required this.onToTap,
    required this.onSwap,
    super.key,
  });

  final ExchangePair pair;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSwap;

  /// El botón de swap es más alto que la píldora; esta es la diferencia.
  static const double _overhang =
      (AppSizes.swapButton - AppSizes.pillHeight) / 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: AppSizes.swapButton,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: _overhang,
            bottom: _overhang,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: colors.outline,
                  width: AppSizes.borderStrong,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: _overhang,
            bottom: _overhang,
            child: Row(
              children: [
                Expanded(
                  child: CurrencySelectorButton(
                    sideLabel: l10n.haveLabel,
                    currency: pair.from,
                    onTap: onFromTap,
                  ),
                ),
                const SizedBox(width: AppSizes.swapButton),
                Expanded(
                  child: CurrencySelectorButton(
                    sideLabel: l10n.wantLabel,
                    currency: pair.to,
                    onTap: onToTap,
                  ),
                ),
              ],
            ),
          ),
          // Etiquetas que cortan el borde superior.
          Positioned(
            left: 0,
            right: 0,
            top: _overhang - 5,
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Expanded(child: _BorderLabel(l10n.haveLabel)),
                  const SizedBox(width: AppSizes.swapButton),
                  Expanded(child: _BorderLabel(l10n.wantLabel)),
                ],
              ),
            ),
          ),
          Center(child: SwapButton(onPressed: onSwap)),
        ],
      ),
    );
  }
}

class _BorderLabel extends StatelessWidget {
  const _BorderLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: ColoredBox(
        color: colors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            text,
            style: AppTypography.overline.copyWith(color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Lado de la píldora: ícono, código y chevron. Abre el selector de moneda.
class CurrencySelectorButton extends StatelessWidget {
  const CurrencySelectorButton({
    required this.sideLabel,
    required this.currency,
    required this.onTap,
    super.key,
  });

  final String sideLabel;
  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.selectorSemantics(sideLabel, currency.code),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CurrencyAvatar(
                currency: currency,
                size: AppSizes.currencyIconSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  currency.code,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: colors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Círculo amarillo que invierte el par; gira media vuelta en cada toque.
class SwapButton extends StatefulWidget {
  const SwapButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  State<SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<SwapButton> {
  double _turns = 0;

  void _handleTap() {
    setState(() => _turns += 0.5);
    HapticFeedback.selectionClick().ignore();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.swapSemantics,
      excludeSemantics: true,
      child: Container(
        width: AppSizes.swapButton,
        height: AppSizes.swapButton,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary,
          border: Border.all(
            color: colors.outline,
            width: AppSizes.borderStrong,
          ),
          boxShadow: AppShadows.raised(colors.shadow),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _handleTap,
            child: AnimatedRotation(
              turns: _turns,
              duration: AppMotion.normal,
              curve: AppMotion.curve,
              child: Icon(
                Icons.swap_horiz_rounded,
                size: 22,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_avatar.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Abre el selector de monedas de un tipo y devuelve la elegida.
/// [isAvailable] deshabilita las monedas que la fuente no cotiza.
Future<Currency?> showCurrencyPicker({
  required BuildContext context,
  required CurrencyType type,
  required Currency selected,
  bool Function(Currency currency)? isAvailable,
}) {
  final l10n = AppLocalizations.of(context);
  return showDsBottomSheet<Currency>(
    context: context,
    title: l10n.pickerTitle(type),
    maxHeightFactor: AppSizes.pickerSheetMaxHeightFactor,
    builder: (context) => CurrencyPickerList(
      currencies: CurrencyCatalog.ofType(type),
      selected: selected,
      isAvailable: isAvailable,
      onSelected: (currency) => Navigator.of(context).pop(currency),
    ),
  );
}

class CurrencyPickerList extends StatelessWidget {
  const CurrencyPickerList({
    required this.currencies,
    required this.selected,
    required this.onSelected,
    this.isAvailable,
    super.key,
  });

  final List<Currency> currencies;
  final Currency selected;
  final ValueChanged<Currency> onSelected;
  final bool Function(Currency currency)? isAvailable;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Se ajusta a la lista: sin espacio vacío debajo de la última moneda.
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      children: [
        for (final currency in currencies)
          CurrencyListTile(
            currency: currency,
            selected: currency == selected,
            enabled:
                currency == selected || (isAvailable?.call(currency) ?? true),
            onTap: () => onSelected(currency),
          ),
      ],
    );
  }
}

/// Fila del selector: ícono, código, nombre (símbolo) y radio.
class CurrencyListTile extends StatelessWidget {
  const CurrencyListTile({
    required this.currency,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  final Currency currency;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final subtitle = enabled
        ? l10n.currencyDescription(currency)
        : '${l10n.currencyDescription(currency)} · ${l10n.unavailableLabel}';

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '${currency.code}, $subtitle',
      excludeSemantics: true,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: SizedBox(
            height: AppSizes.listTileHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  CurrencyAvatar(currency: currency),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.code,
                          style: AppTypography.body.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  DsRadio(selected: selected, enabled: enabled),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

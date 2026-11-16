import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/presentation/widgets/currency_avatar.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Abre el selector de monedas de un tipo y devuelve la elegida.
/// [isAvailable] oculta las monedas que la fuente no cotiza.
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

  /// Las que se pueden elegir. La seleccionada se muestra siempre, aunque
  /// el par actual no esté disponible, para que se vea qué hay elegido.
  List<Currency> get visibleCurrencies => [
    for (final currency in currencies)
      if (currency == selected || (isAvailable?.call(currency) ?? true))
        currency,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Se ajusta a la lista: sin espacio vacío debajo de la última moneda.
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      children: [
        for (final currency in visibleCurrencies)
          CurrencyListTile(
            currency: currency,
            selected: currency == selected,
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
    super.key,
  });

  final Currency currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final subtitle = l10n.currencyDescription(currency);

    return Semantics(
      button: true,
      selected: selected,
      label: '${currency.code}, $subtitle',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
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
                DsRadio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';

/// Una pestaña por [RateProvider]: sumar un proveedor agrega su pestaña.
class ProviderTabs extends StatelessWidget {
  const ProviderTabs({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final RateProvider selected;
  final ValueChanged<RateProvider> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsPillTabs<RateProvider>(
      items: RateProvider.values,
      selected: selected,
      labelOf: l10n.providerName,
      onChanged: onChanged,
      semanticsLabel: l10n.providerTabsLabel,
    );
  }
}

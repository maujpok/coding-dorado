import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// De dónde sale la tasa de la pestaña.
class SourceCaption extends StatelessWidget {
  const SourceCaption({required this.provider, this.quote, super.key});

  final RateProvider provider;
  final ExchangeQuote? quote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final sampleSize = quote?.rate.sampleSize;
    final text = switch (provider) {
      RateProvider.eldorado => l10n.sourceEldorado,
      RateProvider.criptoya =>
        sampleSize == null
            ? l10n.sourceCriptoyaGeneric
            : l10n.sourceCriptoya(sampleSize),
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(color: colors.textSecondary),
    );
  }
}

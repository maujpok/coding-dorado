import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/error/result.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/exchange/presentation/l10n/exchange_l10n.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// Resultado de un proveedor dentro de la comparación.
class ProviderQuoteCard extends StatelessWidget {
  const ProviderQuoteCard({
    required this.provider,
    required this.pair,
    required this.result,
    required this.isBest,
    required this.onUse,
    required this.onRetry,
    this.loading = false,
    super.key,
  });

  final RateProvider provider;
  final ExchangePair pair;

  /// `null` mientras carga por primera vez.
  final Result<ExchangeQuote>? result;
  final bool isBest;
  final bool loading;
  final VoidCallback onUse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final providerName = l10n.providerName(provider);

    return DsCard(
      elevated: false,
      highlighted: isBest,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  providerName,
                  style: AppTypography.bodyStrong.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (isBest) DsBadge(label: l10n.compareBestBadge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedOpacity(
            duration: AppMotion.fast,
            opacity: loading && result != null ? 0.4 : 1,
            child: switch (result) {
              null => const _LoadingBody(),
              Ok(value: final quote) => _QuoteBody(
                quote: quote,
                providerName: providerName,
                onUse: onUse,
              ),
              Err(:final failure) => _FailureBody(
                message: l10n.failureMessage(
                  failure,
                  provider: provider,
                  from: pair.from,
                ),
                canRetry:
                    failure is! PairUnavailableFailure &&
                    failure is! BelowMinimumFailure,
                onRetry: onRetry,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _QuoteBody extends StatelessWidget {
  const _QuoteBody({
    required this.quote,
    required this.providerName,
    required this.onUse,
  });

  final ExchangeQuote quote;
  final String providerName;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final pair = quote.pair;
    final minAmount = quote.rate.minAmount;
    final sampleSize = quote.rate.sampleSize;
    final secondary = AppTypography.caption.copyWith(
      color: colors.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.receiveLabel, style: secondary),
        Semantics(
          label: l10n.approxValueSemantics(
            l10n.receiveLabel,
            AmountFormatter.format(quote.receiveAmount, truncate: true),
            pair.to.code,
          ),
          excludeSemantics: true,
          child: Text(
            '≈ ${AmountFormatter.format(quote.receiveAmount, truncate: true)}'
            ' ${pair.to.code}',
            style: AppTypography.headline.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.compareRate(
            AmountFormatter.format(quote.rate.fiatPerCrypto),
            pair.fiat.code,
          ),
          style: secondary,
        ),
        if (minAmount != null)
          Text(
            l10n.compareMinimum(
              AmountFormatter.format(minAmount),
              pair.from.code,
            ),
            style: secondary,
          ),
        Text(
          switch (quote.provider) {
            RateProvider.eldorado => l10n.compareSourceEldorado,
            RateProvider.criptoya =>
              sampleSize == null
                  ? l10n.sourceCriptoyaGeneric
                  : l10n.compareSourceCriptoya(sampleSize),
          },
          style: secondary,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: DsLink(
            label: l10n.compareUse(providerName),
            icon: Icons.arrow_forward_rounded,
            onPressed: onUse,
          ),
        ),
      ],
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({
    required this.message,
    required this.canRetry,
    required this.onRetry,
  });

  final String message;
  final bool canRetry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: AppTypography.body.copyWith(color: colors.error),
        ),
        if (canRetry) DsLink(label: l10n.retryAction, onPressed: onRetry),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsSkeleton(width: 60),
        SizedBox(height: AppSpacing.sm),
        DsSkeleton(width: 140, height: 18),
        SizedBox(height: AppSpacing.sm),
        DsSkeleton(width: 100),
      ],
    );
  }
}

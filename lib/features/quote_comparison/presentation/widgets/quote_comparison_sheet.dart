import 'dart:async';

import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/features/quote_comparison/domain/entities/quote_comparison.dart';
import 'package:coding_dorado/features/quote_comparison/domain/usecases/compare_quotes.dart';
import 'package:coding_dorado/features/quote_comparison/presentation/cubit/quote_comparison_cubit.dart';
import 'package:coding_dorado/features/quote_comparison/presentation/widgets/provider_quote_card.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abre la comparación. Devuelve el proveedor elegido con "Usar …" o `null`.
Future<RateProvider?> showQuoteComparisonSheet({
  required BuildContext context,
  required CompareQuotes compareQuotes,
  required ExchangePair pair,
  required Decimal amount,
}) {
  final l10n = AppLocalizations.of(context);
  return showDsBottomSheet<RateProvider>(
    context: context,
    title: l10n.compareTitle,
    builder: (sheetContext) => BlocProvider(
      create: (_) {
        final cubit = QuoteComparisonCubit(
          compareQuotes: compareQuotes,
          pair: pair,
          amount: amount,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: QuoteComparisonView(
        providers: compareQuotes.providers.toList(),
        onUse: (provider) => Navigator.of(sheetContext).pop(provider),
      ),
    ),
  );
}

class QuoteComparisonView extends StatelessWidget {
  const QuoteComparisonView({
    required this.providers,
    required this.onUse,
    super.key,
  });

  final List<RateProvider> providers;
  final ValueChanged<RateProvider> onUse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final cubit = context.watch<QuoteComparisonCubit>();
    final state = cubit.state;
    final comparison = state.comparison;
    final loading = state is ComparisonLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: l10n.compareSubject(
                    AmountFormatter.format(cubit.amount),
                    cubit.pair.from.code,
                    cubit.pair.to.code,
                  ),
                  excludeSemantics: true,
                  child: _Subject(
                    from:
                        '${AmountFormatter.format(cubit.amount)} '
                        '${cubit.pair.from.code}',
                    to: cubit.pair.to.code,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.compareRefresh,
                onPressed: loading ? null : cubit.refresh,
                icon: Icon(Icons.refresh_rounded, color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final provider in providers) ...[
            ProviderQuoteCard(
              provider: provider,
              pair: cubit.pair,
              result: comparison?.results[provider],
              isBest: comparison?.best == provider,
              loading: loading,
              onUse: () => onUse(provider),
              onRetry: cubit.refresh,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (comparison != null) _Summary(comparison: comparison),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.compareFootnote,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.comparison});

  final QuoteComparison comparison;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final best = comparison.best;
    final difference = comparison.difference;
    final percent = comparison.differencePercent;
    final quotes = comparison.quotes;

    final String text;
    var positive = false;
    if (best != null && difference != null && percent != null) {
      positive = true;
      text = l10n.compareWinner(
        l10n.providerName(best),
        AmountFormatter.signed(difference, truncate: true),
        comparison.pair.to.code,
        AmountFormatter.percent(percent),
      );
    } else if (comparison.isTie) {
      text = l10n.compareTie;
    } else if (quotes.length == 1) {
      text = l10n.compareOnlyOne(l10n.providerName(quotes.single.provider));
    } else {
      text = l10n.compareNone;
    }

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: positive ? colors.successContainer : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.bodyStrong.copyWith(
            color: positive ? colors.success : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// "5.00 USDT → VES" con la flecha como ícono (Rubik no tiene el glifo).
class _Subject extends StatelessWidget {
  const _Subject({required this.from, required this.to});

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = AppTypography.bodyStrong.copyWith(
      color: colors.textSecondary,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(from, style: style),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: AppSizes.iconSmall,
              color: colors.textSecondary,
            ),
          ),
          Text(to, style: style),
        ],
      ),
    );
  }
}

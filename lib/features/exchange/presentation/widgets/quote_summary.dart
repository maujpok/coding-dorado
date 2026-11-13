import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/presentation/bloc/exchange_bloc.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// Tasa estimada, monto a recibir y tiempo estimado.
///
/// - Sin monto: valores vacíos ("—").
/// - Cargando: conserva el valor anterior atenuado o muestra skeletons, sin
///   cambiar el alto de las filas.
/// - Con error: no muestra valores; el mensaje lo dibuja `QuoteMessage`.
class QuoteSummary extends StatelessWidget {
  const QuoteSummary({required this.pair, required this.status, super.key});

  final ExchangePair pair;
  final QuoteStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quote = status.latestQuote;
    final isLoading = status is QuoteLoading;
    final hasQuote = quote != null && status is! QuoteFailed;
    final showTime = !hasQuote || quote.rate.estimatedTime != null;

    String? valueOr(String Function(ExchangeQuote q) read) =>
        hasQuote ? read(quote) : null;

    final rows = [
      _RowData(
        label: l10n.estimatedRateLabel,
        unit: pair.fiat.code,
        value: valueOr(
          (q) => AmountFormatter.format(q.rate.fiatPerCrypto),
        ),
      ),
      _RowData(
        label: l10n.receiveLabel,
        unit: pair.to.code,
        value: valueOr(
          (q) => AmountFormatter.format(q.receiveAmount, truncate: true),
        ),
      ),
      if (showTime)
        _RowData(
          label: l10n.estimatedTimeLabel,
          unit: l10n.minutesUnit,
          value: valueOr((q) => '${q.rate.estimatedTime?.inMinutes ?? ''}'),
        ),
    ];

    return Column(
      children: [
        for (final row in rows)
          QuoteRow(
            label: row.label,
            value: row.value,
            unit: row.unit,
            loading: isLoading,
          ),
      ],
    );
  }
}

class _RowData {
  const _RowData({required this.label, required this.unit, this.value});

  final String label;
  final String unit;
  final String? value;
}

/// "Etiqueta ......... ≈ valor UNIDAD".
class QuoteRow extends StatelessWidget {
  const QuoteRow({
    required this.label,
    required this.value,
    required this.unit,
    this.loading = false,
    super.key,
  });

  final String label;

  /// `null`: sin valor (vacío o cargando sin valor previo).
  final String? value;
  final String unit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final value = this.value;

    final Widget trailing;
    if (value == null && loading) {
      trailing = const DsSkeleton(width: 72);
    } else if (value == null) {
      trailing = Text(
        l10n.emptyValue,
        style: AppTypography.body.copyWith(color: colors.textDisabled),
      );
    } else {
      trailing = AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: loading ? 0.4 : 1,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '≈ ',
                style: AppTypography.caption.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              TextSpan(
                text: value,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
              TextSpan(
                text: ' $unit',
                style: AppTypography.caption.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          maxLines: 1,
        ),
      );
    }

    return Semantics(
      label: value == null
          ? label
          : l10n.approxValueSemantics(label, value, unit),
      excludeSemantics: true,
      child: SizedBox(
        height: AppSizes.quoteRowHeight,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // El valor queda pegado a la derecha y, con textos grandes, se
              // achica en lugar de desbordar.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.6,
                ),
                child: FittedBox(fit: BoxFit.scaleDown, child: trailing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

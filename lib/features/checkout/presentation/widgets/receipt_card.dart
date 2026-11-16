import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/presentation/widgets/success_mark.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:coding_dorado/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprobante: el check sobre el borde superior de la tarjeta, el título,
/// lo recibido, el detalle y el ID para copiar.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({required this.transaction, super.key});

  final ExchangeTransaction transaction;

  /// El centro del check queda sobre el borde de la tarjeta.
  static const double _markOverlap = SuccessMark.extent / 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _markOverlap),
          child: DsCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              SuccessMark.size / 2 + AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    l10n.successTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.display.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.successSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _Amounts(transaction: transaction),
                const SizedBox(height: AppSpacing.lg),
                Divider(height: 1, thickness: 1, color: colors.outlineSubtle),
                const SizedBox(height: AppSpacing.sm),
                _Details(transaction: transaction),
                const SizedBox(height: AppSpacing.md),
                TransactionIdField(id: transaction.id),
              ],
            ),
          ),
        ),
        const SuccessMark(),
      ],
    );
  }
}

/// "Recibiste 125.00 VES por 5.00 USDT".
class _Amounts extends StatelessWidget {
  const _Amounts({required this.transaction});

  final ExchangeTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final quote = transaction.quote;
    return MergeSemantics(
      child: Column(
        children: [
          Text(
            l10n.receiptReceived,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${AmountFormatter.format(quote.receiveAmount, truncate: true)} '
              '${quote.pair.to.code}',
              style: AppTypography.display.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.receiptSent(
              AmountFormatter.format(quote.amount),
              quote.pair.from.code,
            ),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Tasa, fuente, fecha, hora y estado.
class _Details extends StatelessWidget {
  const _Details({required this.transaction});

  final ExchangeTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localizations = MaterialLocalizations.of(context);
    final quote = transaction.quote;
    final pair = quote.pair;
    final completedAt = transaction.completedAt;
    return Column(
      children: [
        ReceiptRow(
          label: l10n.receiptRate,
          value: l10n.receiptRateValue(
            pair.crypto.code,
            AmountFormatter.format(quote.rate.fiatPerCrypto),
            pair.fiat.code,
          ),
        ),
        ReceiptRow(
          label: l10n.sourceLabel,
          value: l10n.providerName(quote.provider),
        ),
        ReceiptRow(
          label: l10n.receiptDate,
          value: localizations.formatCompactDate(completedAt),
        ),
        ReceiptRow(
          label: l10n.receiptTime,
          value: localizations.formatTimeOfDay(
            TimeOfDay.fromDateTime(completedAt),
            alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
          ),
        ),
        ReceiptRow(
          label: l10n.receiptStatus,
          child: DsBadge(
            label: l10n.receiptStatusCompleted,
            tone: DsBadgeTone.success,
          ),
        ),
      ],
    );
  }
}

/// "Etiqueta ........ valor". [child] reemplaza al texto del valor (por
/// ejemplo, una insignia).
class ReceiptRow extends StatelessWidget {
  const ReceiptRow({required this.label, this.value, this.child, super.key})
    : assert(value != null || child != null, 'Falta el valor.');

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 34),
        child: Row(
          // El espacio que no usa la etiqueta queda en el medio: el valor
          // siempre llega al borde derecho.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child:
                    child ??
                    Text(
                      value!,
                      textAlign: TextAlign.end,
                      style: AppTypography.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// El ID de la transacción en su propio bloque, con el botón para copiarlo.
class TransactionIdField extends StatelessWidget {
  const TransactionIdField({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.receiptId,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  id,
                  maxLines: 1,
                  style: AppTypography.bodyStrong.copyWith(
                    color: colors.textPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.copyIdAction,
                iconSize: AppSizes.iconMedium,
                color: colors.textPrimary,
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).idCopied;
    await Clipboard.setData(ClipboardData(text: id));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

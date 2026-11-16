import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/checkout/domain/entities/exchange_transaction.dart';
import 'package:coding_dorado/features/checkout/presentation/pages/checkout_page_frame.dart';
import 'package:coding_dorado/features/checkout/presentation/widgets/receipt_card.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pantalla completa de cambio exitoso, con el comprobante. "Volver al
/// inicio" y "atrás" regresan a la calculadora.
class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({required this.transaction, super.key});

  static Route<void> route(ExchangeTransaction transaction) =>
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: 'checkout/success'),
        transitionDuration: AppMotion.slow,
        reverseTransitionDuration: AppMotion.normal,
        pageBuilder: (context, _, _) =>
            CheckoutSuccessPage(transaction: transaction),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppMotion.curve),
          child: child,
        ),
      );

  final ExchangeTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    // El título va dentro de la tarjeta, así no queda sobre el borde del
    // semicírculo del fondo.
    return Scaffold(
      body: DsBackground(
        child: CheckoutPageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReceiptCard(transaction: transaction),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.simulationNote,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              DsPrimaryButton(
                label: l10n.successDone,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

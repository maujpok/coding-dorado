import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Acción de un [QuoteMessage].
class QuoteMessageAction {
  const QuoteMessageAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

enum QuoteMessageTone {
  /// Algo falló (red, servidor, respuesta inválida).
  error,

  /// No es un error: la fuente no cotiza el par o no tiene ofertas.
  info,
}

/// Mensaje de error o de aviso dentro de la tarjeta, con acciones opcionales.
class QuoteMessage extends StatelessWidget {
  const QuoteMessage({
    required this.message,
    this.actions = const [],
    this.tone = QuoteMessageTone.error,
    super.key,
  });

  final String message;
  final List<QuoteMessageAction> actions;
  final QuoteMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isError = tone == QuoteMessageTone.error;
    final foreground = isError ? colors.error : colors.textPrimary;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isError ? colors.errorContainer : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.caption.copyWith(
                      color: foreground,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.md,
                children: [
                  for (final action in actions)
                    DsLink(label: action.label, onPressed: action.onPressed),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

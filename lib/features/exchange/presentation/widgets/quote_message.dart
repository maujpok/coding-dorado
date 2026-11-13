import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Acción de un [QuoteMessage].
class QuoteMessageAction {
  const QuoteMessageAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// Mensaje de error o de aviso dentro de la tarjeta, con acciones opcionales.
class QuoteMessage extends StatelessWidget {
  const QuoteMessage({
    required this.message,
    this.actions = const [],
    super.key,
  });

  final String message;
  final List<QuoteMessageAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: colors.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.caption.copyWith(
                      color: colors.error,
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

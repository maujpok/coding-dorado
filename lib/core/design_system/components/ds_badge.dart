import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:coding_dorado/core/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

enum DsBadgeTone {
  /// Amarillo con texto en tinta.
  brand,

  /// Verde suave con texto verde oscuro (estados completados).
  success,
}

/// Etiqueta destacada: amarillo con texto en tinta (como las etiquetas del
/// blog de eldorado.io) o, para estados, en el tono de éxito.
class DsBadge extends StatelessWidget {
  const DsBadge({
    required this.label,
    this.textStyle,
    this.tone = DsBadgeTone.brand,
    super.key,
  });

  final String label;

  /// Por defecto `AppTypography.label`.
  final TextStyle? textStyle;
  final DsBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = switch (tone) {
      DsBadgeTone.brand => (colors.primary, colors.onPrimary),
      DsBadgeTone.success => (colors.successContainer, colors.success),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + AppSpacing.xxs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: (textStyle ?? AppTypography.label).copyWith(
            color: foreground,
          ),
        ),
      ),
    );
  }
}

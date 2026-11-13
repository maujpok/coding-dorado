import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:coding_dorado/core/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Etiqueta destacada: amarillo con texto en tinta (como las etiquetas del
/// blog de eldorado.io).
class DsBadge extends StatelessWidget {
  const DsBadge({required this.label, this.textStyle, super.key});

  final String label;

  /// Por defecto `AppTypography.label`.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
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
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}

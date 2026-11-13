import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:coding_dorado/core/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Acción principal: relleno amarillo, texto y borde en tinta.
/// `onPressed == null` la deshabilita.
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Muestra un indicador y bloquea la acción.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(AppRadius.control);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: AppSizes.buttonHeight,
        decoration: BoxDecoration(
          color: enabled || isLoading ? colors.primary : colors.surfaceMuted,
          borderRadius: radius,
          border: Border.all(
            color: enabled || isLoading ? colors.outline : colors.outlineSubtle,
            width: AppSizes.borderStrong,
          ),
          boxShadow: enabled ? AppShadows.raised(colors.shadow) : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: radius,
            splashColor: colors.primaryPressed,
            highlightColor: colors.primaryPressed,
            child: Center(
              child: isLoading
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: AppTypography.button.copyWith(
                        color: enabled ? colors.onPrimary : colors.textDisabled,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enlace de texto: tinta con subrayado amarillo grueso, como los enlaces
/// de eldorado.io.
class DsLink extends StatelessWidget {
  const DsLink({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final color = enabled ? colors.textPrimary : colors.textDisabled;
    return Semantics(
      link: true,
      enabled: enabled,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodyStrong.copyWith(
                    color: color,
                    decoration: TextDecoration.underline,
                    decorationColor: enabled
                        ? colors.outline
                        : colors.textDisabled,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Superficie elevada: la tarjeta de la calculadora y las tarjetas de la
/// comparación.
class DsCard extends StatelessWidget {
  const DsCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.elevated = true,
    this.highlighted = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Con sombra (tarjeta principal) o plana (dentro de un sheet).
  final bool elevated;

  /// Borde en tinta para destacar (por ejemplo, la mejor opción).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: highlighted ? colors.outline : colors.outlineSubtle,
          width: highlighted ? AppSizes.borderStrong : AppSizes.borderThin,
        ),
        boxShadow: elevated ? AppShadows.card(colors.shadow) : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

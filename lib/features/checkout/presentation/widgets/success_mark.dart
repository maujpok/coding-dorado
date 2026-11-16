import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Check en un disco amarillo que entra con rebote y suelta una onda.
class SuccessMark extends StatelessWidget {
  const SuccessMark({super.key});

  /// Diámetro del disco.
  static const double size = 88;

  /// Lado del área que ocupa, con espacio para la onda.
  static const double extent = size * 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        builder: (context, t, child) {
          final ring = Curves.easeOutCubic.transform(t);
          return SizedBox.square(
            dimension: extent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size * (1 + 0.5 * ring),
                  height: size * (1 + 0.5 * ring),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.6 * (1 - ring)),
                      width: AppSizes.ringWidth,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: Curves.elasticOut.transform(t),
                  child: child,
                ),
              ],
            ),
          );
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.outline,
              width: AppSizes.ringWidth,
            ),
            boxShadow: AppShadows.raised(colors.shadow),
          ),
          child: Icon(
            Icons.check_rounded,
            size: size * 0.55,
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}

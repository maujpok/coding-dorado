import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Fondo de pantalla con el semicírculo del diseño.
///
/// La geometría se ajustó al diseño (error < 1 px): centro en
/// (1.945·ancho, 0.378·alto) y radio 1.403·ancho.
class DsBackground extends StatelessWidget {
  const DsBackground({required this.child, this.decorationColor, super.key});

  final Widget child;

  /// Color del semicírculo; por defecto `AppColors.backgroundDecoration`.
  /// Los cambios se animan.
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final target = decorationColor ?? colors.backgroundDecoration;
    return ColoredBox(
      color: colors.background,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: target),
        duration: AppMotion.slow,
        curve: AppMotion.curve,
        builder: (context, color, child) => CustomPaint(
          painter: _CirclePainter(color ?? target),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  const _CirclePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 1.945, size.height * 0.378);
    canvas.drawCircle(center, size.width * 1.403, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => oldDelegate.color != color;
}

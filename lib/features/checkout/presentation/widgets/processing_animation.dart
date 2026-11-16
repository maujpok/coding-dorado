import 'dart:math' as math;

import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Disco en tinta con el ícono de intercambio, que gira media vuelta por
/// ciclo, y dos ondas que se expanden. Pensada para el fondo amarillo.
class ProcessingAnimation extends StatefulWidget {
  const ProcessingAnimation({this.size = 136, super.key});

  final double size;

  @override
  State<ProcessingAnimation> createState() => _ProcessingAnimationState();
}

class _ProcessingAnimationState extends State<ProcessingAnimation>
    with SingleTickerProviderStateMixin {
  static const _discSize = 72.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = widget.size;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                for (final phase in const [0.0, 0.5])
                  _Ripple(
                    progress: (t + phase) % 1,
                    minSize: _discSize,
                    maxSize: size,
                    color: colors.onPrimary,
                  ),
                Transform.rotate(
                  angle: Curves.easeInOutCubic.transform(t) * math.pi,
                  child: child,
                ),
              ],
            );
          },
          child: Container(
            width: _discSize,
            height: _discSize,
            decoration: BoxDecoration(
              color: colors.inverseSurface,
              shape: BoxShape.circle,
              boxShadow: AppShadows.raised(colors.shadow),
            ),
            child: Icon(
              Icons.swap_horiz_rounded,
              size: 36,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Ripple extends StatelessWidget {
  const _Ripple({
    required this.progress,
    required this.minSize,
    required this.maxSize,
    required this.color,
  });

  final double progress;
  final double minSize;
  final double maxSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeOut.transform(progress);
    final diameter = minSize + (maxSize - minSize) * eased;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.5 * (1 - progress)),
          width: AppSizes.ringWidth,
        ),
      ),
    );
  }
}

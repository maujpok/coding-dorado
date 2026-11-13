import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Marcador de contenido que está cargando: un bloque que pulsa.
class DsSkeleton extends StatefulWidget {
  const DsSkeleton({required this.width, this.height = 12, super.key});

  final double width;
  final double height;

  @override
  State<DsSkeleton> createState() => _DsSkeletonState();
}

class _DsSkeletonState extends State<DsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.outlineSubtle,
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
        ),
      ),
    );
  }
}

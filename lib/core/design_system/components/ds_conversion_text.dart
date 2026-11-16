import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:flutter/material.dart';

/// "5.00 USDT → VES" con la flecha como ícono: Rubik no trae el glifo "→".
/// Se achica en lugar de desbordar.
class DsConversionText extends StatelessWidget {
  const DsConversionText({
    required this.from,
    required this.to,
    required this.style,
    super.key,
  });

  final String from;
  final String to;

  /// Estilo de ambos textos; la flecha toma su color.
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(from, style: style),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: AppSizes.iconSmall,
              color: style.color,
            ),
          ),
          Text(to, style: style),
        ],
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Indicador de selección (solo visual: la fila entera es el control).
/// Seleccionado: anillo en tinta, relleno amarillo y punto central.
class DsRadio extends StatelessWidget {
  const DsRadio({required this.selected, this.enabled = true, super.key});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ring = !enabled
        ? colors.outlineSubtle
        : selected
        ? colors.outline
        : colors.fieldBorder;
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: AppSizes.radio,
      height: AppSizes.radio,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.primary : Colors.transparent,
        border: Border.all(color: ring, width: AppSizes.ringWidth),
      ),
      child: Center(
        child: AnimatedScale(
          duration: AppMotion.fast,
          scale: selected ? 1 : 0,
          child: Container(
            width: AppSizes.radioDot,
            height: AppSizes.radioDot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

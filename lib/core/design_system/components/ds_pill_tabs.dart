import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:coding_dorado/core/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Selector de pestañas segmentado: píldora en tinta, la pestaña activa
/// rellena en amarillo (como el header de eldorado.io).
class DsPillTabs<T> extends StatelessWidget {
  const DsPillTabs({
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.semanticsLabel,
    super.key,
  });

  final List<T> items;
  final T selected;
  final String Function(T item) labelOf;
  final ValueChanged<T> onChanged;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedIndex = items.indexOf(selected);

    return Semantics(
      label: semanticsLabel,
      container: true,
      child: Container(
        height: AppSizes.tabsHeight,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Stack(
          children: [
            // Indicador que se desliza bajo la pestaña activa.
            AnimatedAlign(
              duration: AppMotion.normal,
              curve: AppMotion.curve,
              alignment: Alignment(
                items.length == 1
                    ? 0
                    : -1 + 2 * selectedIndex / (items.length - 1),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / items.length,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: _Tab(
                      label: labelOf(item),
                      selected: item == selected,
                      onTap: () => onChanged(item),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.fast,
            style: AppTypography.bodyStrong.copyWith(
              color: selected ? colors.onPrimary : colors.onInverseSurface,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}

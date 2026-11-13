import 'package:coding_dorado/core/design_system/theme/design_system_context.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:coding_dorado/core/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Abre un bottom sheet del design system: handle, título centrado y
/// contenido. Con [heightFactor] ocupa esa fracción de la pantalla (los
/// selectores de moneda usan 0.7, como el mock); sin él, se ajusta al
/// contenido.
Future<T?> showDsBottomSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  double? heightFactor,
  Widget? trailing,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final sheet = DsSheetScaffold(
        title: title,
        trailing: trailing,
        expand: heightFactor != null,
        child: builder(context),
      );
      return heightFactor == null
          ? sheet
          : FractionallySizedBox(heightFactor: heightFactor, child: sheet);
    },
  );
}

/// Estructura de un sheet: handle, título y contenido.
class DsSheetScaffold extends StatelessWidget {
  const DsSheetScaffold({
    required this.title,
    required this.child,
    this.trailing,
    this.expand = false,
    super.key,
  });

  final String title;
  final Widget child;

  /// Acción opcional a la derecha del título.
  final Widget? trailing;

  /// Si el contenido ocupa todo el alto disponible.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: child,
    );
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: AppSizes.sheetHandleWidth,
              height: AppSizes.sheetHandleHeight,
              decoration: BoxDecoration(
                color: colors.handle,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                SizedBox(width: trailing == null ? 0 : AppSpacing.huge),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: trailing == null ? 0 : AppSpacing.huge,
                  child: trailing,
                ),
              ],
            ),
          ),
          if (expand) Expanded(child: content) else Flexible(child: content),
        ],
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/tokens/app_colors.dart';
import 'package:coding_dorado/core/design_system/tokens/app_dimensions.dart';
import 'package:coding_dorado/core/design_system/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Arma el [ThemeData] de Material a partir de los tokens, para que los
/// widgets de Flutter (snackbars, selección de texto, sheets) también los
/// respeten.
abstract final class AppTheme {
  static ThemeData light() => _build(AppColors.light);

  static ThemeData _build(AppColors colors) {
    final scheme = ColorScheme.light(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.inverseSurface,
      onSecondary: colors.onInverseSurface,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.fieldBorder,
      outlineVariant: colors.outlineSubtle,
      error: colors.error,
      errorContainer: colors.errorContainer,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.onInverseSurface,
      scrim: colors.scrim,
      shadow: colors.shadow,
    );

    final textTheme = const TextTheme(
      titleLarge: AppTypography.title,
      titleMedium: AppTypography.headline,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      labelSmall: AppTypography.overline,
    ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      extensions: [colors],
      splashFactory: InkSparkle.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.textPrimary,
        selectionColor: colors.primary.withValues(alpha: 0.6),
        selectionHandleColor: colors.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: colors.scrim,
        showDragHandle: false,
        constraints: const BoxConstraints(maxWidth: AppSizes.sheetMaxWidth),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: AppTypography.body.copyWith(
          color: colors.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}

import 'package:coding_dorado/core/design_system/tokens/app_palette.dart';
import 'package:flutter/material.dart';

/// Tokens semánticos de color. Los widgets piden un rol ("borde de un campo",
/// "texto secundario"), nunca un color concreto.
///
/// Regla de marca: el amarillo de El Dorado se usa como **relleno** con texto
/// y bordes en tinta. Sobre blanco no se usa como texto ni como borde porque
/// su contraste es de 1.07:1.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.backgroundDecoration,
    required this.surface,
    required this.surfaceMuted,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.outline,
    required this.outlineSubtle,
    required this.handle,
    required this.fieldBorder,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.success,
    required this.successContainer,
    required this.error,
    required this.errorContainer,
    required this.scrim,
    required this.shadow,
  });

  static const light = AppColors(
    background: AppPalette.grey200,
    backgroundDecoration: AppPalette.yellow,
    surface: AppPalette.grey50,
    surfaceMuted: AppPalette.grey100,
    primary: AppPalette.yellow,
    primaryPressed: AppPalette.yellowDeep,
    onPrimary: AppPalette.ink,
    textPrimary: AppPalette.ink,
    textSecondary: AppPalette.grey700,
    textDisabled: AppPalette.grey500,
    outline: AppPalette.ink,
    outlineSubtle: AppPalette.grey300,
    handle: AppPalette.grey400,
    fieldBorder: AppPalette.grey700,
    inverseSurface: AppPalette.ink,
    onInverseSurface: AppPalette.grey50,
    success: AppPalette.greenInk,
    successContainer: AppPalette.greenTint,
    error: AppPalette.redInk,
    errorContainer: AppPalette.redTint,
    scrim: Color(0x40000000),
    shadow: AppPalette.black,
  );

  /// Fondo de las pantallas.
  final Color background;

  /// Forma decorativa del fondo (el semicírculo del diseño).
  final Color backgroundDecoration;

  /// Tarjetas y bottom sheets.
  final Color surface;

  /// Superficies secundarias: skeletons, estados deshabilitados.
  final Color surfaceMuted;

  /// Relleno de acciones principales y elementos destacados.
  final Color primary;
  final Color primaryPressed;

  /// Texto e íconos sobre [primary].
  final Color onPrimary;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  /// Bordes con peso visual (selector de monedas, botones).
  final Color outline;

  /// Bordes y divisores discretos.
  final Color outlineSubtle;

  /// Handle de los bottom sheets.
  final Color handle;

  /// Borde de los campos en reposo; en foco se usa [outline].
  final Color fieldBorder;

  /// Superficie oscura (selector de pestañas) y su contenido.
  final Color inverseSurface;
  final Color onInverseSurface;

  final Color success;
  final Color successContainer;
  final Color error;
  final Color errorContainer;

  /// Velo detrás de los bottom sheets.
  final Color scrim;
  final Color shadow;

  @override
  AppColors copyWith({
    Color? background,
    Color? backgroundDecoration,
    Color? surface,
    Color? surfaceMuted,
    Color? primary,
    Color? primaryPressed,
    Color? onPrimary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? outline,
    Color? outlineSubtle,
    Color? handle,
    Color? fieldBorder,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? success,
    Color? successContainer,
    Color? error,
    Color? errorContainer,
    Color? scrim,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      outline: outline ?? this.outline,
      outlineSubtle: outlineSubtle ?? this.outlineSubtle,
      handle: handle ?? this.handle,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: mix(background, other.background),
      backgroundDecoration: mix(
        backgroundDecoration,
        other.backgroundDecoration,
      ),
      surface: mix(surface, other.surface),
      surfaceMuted: mix(surfaceMuted, other.surfaceMuted),
      primary: mix(primary, other.primary),
      primaryPressed: mix(primaryPressed, other.primaryPressed),
      onPrimary: mix(onPrimary, other.onPrimary),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textDisabled: mix(textDisabled, other.textDisabled),
      outline: mix(outline, other.outline),
      outlineSubtle: mix(outlineSubtle, other.outlineSubtle),
      handle: mix(handle, other.handle),
      fieldBorder: mix(fieldBorder, other.fieldBorder),
      inverseSurface: mix(inverseSurface, other.inverseSurface),
      onInverseSurface: mix(onInverseSurface, other.onInverseSurface),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      error: mix(error, other.error),
      errorContainer: mix(errorContainer, other.errorContainer),
      scrim: mix(scrim, other.scrim),
      shadow: mix(shadow, other.shadow),
    );
  }
}

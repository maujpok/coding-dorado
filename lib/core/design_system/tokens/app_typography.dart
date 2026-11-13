import 'package:flutter/painting.dart';

/// Escala tipográfica. Los tamaños se midieron en los mocks (804×1748 px a
/// @2x) con la altura de mayúsculas de Rubik (0.7 em). Los estilos no llevan
/// color: lo pone cada componente con los tokens de `AppColors`.
abstract final class AppTypography {
  static const fontFamily = 'Rubik';

  /// Títulos de bottom sheets ("FIAT", "Cripto").
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.2,
  );

  /// Montos destacados (comparación de cotizaciones).
  static const headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Texto base: etiquetas del resumen, valores, monto ingresado.
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.3,
  );

  static const bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.2,
  );

  /// Códigos de moneda en el selector, insignias.
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  /// Unidades, subtítulos, notas.
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.3,
  );

  /// Etiquetas en mayúsculas sobre bordes ("TENGO", "QUIERO").
  static const overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.5,
    height: 1,
    letterSpacing: 0.4,
  );
}

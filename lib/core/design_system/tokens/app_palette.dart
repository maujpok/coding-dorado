import 'package:flutter/painting.dart';

/// Colores primitivos. Los componentes no los usan directamente: pasan por
/// los tokens semánticos de `AppColors`.
///
/// La marca sale del sitio de El Dorado (eldorado.io), variables CSS
/// `--amarillo-el-dorado`, `--fondo-gris`, `--gris-bordes` y los neutros que
/// más usa su hoja de estilos.
abstract final class AppPalette {
  // Marca
  static const yellow = Color(0xFFFFFF00); // --amarillo-el-dorado
  static const yellowDeep = Color(0xFFE5E517); // amarillo de estados activos
  static const ink = Color(0xFF121211); // texto principal del sitio
  static const black = Color(0xFF000000);

  // Neutros
  static const grey50 = Color(0xFFFCFCFC);
  static const grey100 = Color(0xFFF1F1F0);
  static const grey200 = Color(0xFFE6E6E4); // --fondo-gris
  static const grey300 = Color(0xFFDADAD7);
  static const grey500 = Color(0xFF8E8E88);
  static const grey700 = Color(0xFF5B5B55); // --gris-bordes
  static const white = Color(0xFFFFFFFF);

  // Acentos del sitio (fondos y detalles, nunca texto sobre claro)
  static const green = Color(0xFF5DFF85);
  static const blue = Color(0xFF4F4FEB);

  // Variantes legibles sobre fondos claros (contraste AA)
  static const greenInk = Color(0xFF0B6B2E);
  static const greenTint = Color(0xFFE3FFE9);
  static const redInk = Color(0xFFB3261E);
  static const redTint = Color(0xFFFDECEA);
}

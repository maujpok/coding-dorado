import 'package:flutter/widgets.dart';

/// Espaciados en una escala de 4 pt.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

/// Radios de esquina, medidos en los mocks.
abstract final class AppRadius {
  static const double badge = 4; // insignias, prefijo del monto
  static const double icon = 5; // íconos de moneda
  static const double control = 10; // campos y botones
  static const double card = 17; // tarjeta de la calculadora
  static const double sheet = 20; // bottom sheets
  static const double pill = 999;
}

/// Tamaños de controles, medidos en los mocks (402×874 pt).
abstract final class AppSizes {
  static const double pillHeight = 33;
  static const double fieldHeight = 38;
  static const double buttonHeight = 41;
  static const double swapButton = 41;
  static const double tabsHeight = 40;
  static const double currencyIconSmall = 20;
  static const double currencyIconLarge = 24;
  static const double radio = 22;
  static const double radioDot = 8;
  static const double listTileHeight = 62;
  static const double quoteRowHeight = 28;
  static const double sheetHandleWidth = 62;
  static const double sheetHandleHeight = 4;
  static const double borderThin = 1;
  static const double borderStrong = 1.5;
  static const double ringWidth = 2;

  /// Ancho máximo del contenido en tablet y web.
  static const double contentMaxWidth = 400;
  static const double sheetMaxWidth = 520;

  /// Fracción de la pantalla que ocupa el selector de monedas.
  static const double pickerSheetHeightFactor = 0.7;
}

/// Reglas de layout responsive.
abstract final class AppLayout {
  /// Margen lateral del contenido: 48 pt en teléfonos como el del mock
  /// (402 pt → tarjeta de ~306 pt) y 16 pt en pantallas angostas.
  static double horizontalMargin(double width) => width >= 380 ? 48 : 16;
}

/// Sombras.
abstract final class AppShadows {
  static List<BoxShadow> card(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.10),
      blurRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> raised(Color shadow) => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.18),
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];
}

/// Duraciones y curvas de animación.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const Curve curve = Curves.easeOutCubic;
}

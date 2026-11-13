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

/// Radios de esquina.
abstract final class AppRadius {
  static const double xs = 4; // insignias, chips
  static const double sm = 6; // íconos de moneda
  static const double md = 10; // campos de texto
  static const double lg = 12; // botones
  static const double xl = 20; // bottom sheets
  static const double xxl = 24; // tarjetas
  static const double pill = 999;
}

/// Tamaños de controles, medidos en los mocks.
abstract final class AppSizes {
  static const double pillHeight = 34;
  static const double fieldHeight = 40;
  static const double buttonHeight = 44;
  static const double swapButton = 41;
  static const double tabsHeight = 40;
  static const double currencyIconSmall = 20;
  static const double currencyIconLarge = 24;
  static const double radio = 22;
  static const double listTileHeight = 62;
  static const double sheetHandleWidth = 62;
  static const double sheetHandleHeight = 4;
  static const double borderThin = 1;
  static const double borderStrong = 1.5;

  /// Ancho máximo del contenido en tablet y web.
  static const double contentMaxWidth = 400;
  static const double sheetMaxWidth = 520;
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

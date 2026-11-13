import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contraste WCAG 2.x entre dos colores opacos.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (light, dark) = la > lb ? (la, lb) : (lb, la);
  return (light + 0.05) / (dark + 0.05);
}

void main() {
  const c = AppColors.light;

  group('Contraste de los tokens de color', () {
    // Texto: AA exige 4.5:1.
    final textPairs = <String, (Color, Color)>{
      'textPrimary / surface': (c.textPrimary, c.surface),
      'textPrimary / background': (c.textPrimary, c.background),
      'textSecondary / surface': (c.textSecondary, c.surface),
      'textSecondary / background': (c.textSecondary, c.background),
      'onPrimary / primary': (c.onPrimary, c.primary),
      'onPrimary / primaryPressed': (c.onPrimary, c.primaryPressed),
      'onInverseSurface / inverseSurface': (
        c.onInverseSurface,
        c.inverseSurface,
      ),
      'primary / inverseSurface': (c.primary, c.inverseSurface),
      'error / surface': (c.error, c.surface),
      'error / errorContainer': (c.error, c.errorContainer),
      'success / successContainer': (c.success, c.successContainer),
    };
    for (final MapEntry(key: name, value: (fg, bg)) in textPairs.entries) {
      test('$name ≥ 4.5:1', () {
        expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
      });
    }

    // Componentes de UI (bordes, íconos): AA exige 3:1.
    final uiPairs = <String, (Color, Color)>{
      'outline / surface': (c.outline, c.surface),
      'fieldBorder / surface': (c.fieldBorder, c.surface),
    };
    for (final MapEntry(key: name, value: (fg, bg)) in uiPairs.entries) {
      test('$name ≥ 3:1', () {
        expect(contrast(fg, bg), greaterThanOrEqualTo(3));
      });
    }

    test('el amarillo de marca no sirve como texto sobre superficie', () {
      // Documenta la regla: amarillo solo como relleno.
      expect(contrast(c.primary, c.surface), lessThan(1.5));
    });
  });

  test('AppTheme expone los tokens como extensión', () {
    final theme = AppTheme.light();

    expect(theme.extension<AppColors>(), AppColors.light);
    expect(theme.colorScheme.primary, AppColors.light.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.light.background);
  });
}

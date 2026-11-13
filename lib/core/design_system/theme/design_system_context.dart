import 'package:coding_dorado/core/design_system/tokens/app_colors.dart';
import 'package:flutter/material.dart';

extension DesignSystemContext on BuildContext {
  /// Tokens de color del tema activo.
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

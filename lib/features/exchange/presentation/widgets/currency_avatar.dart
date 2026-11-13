import 'package:coding_dorado/core/design_system/design_system.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:flutter/material.dart';

/// Ícono de una moneda. Sin asset (ARS, BOB, USDC) muestra su código sobre
/// el amarillo de la marca.
class CurrencyAvatar extends StatelessWidget {
  const CurrencyAvatar({
    required this.currency,
    this.size = AppSizes.currencyIconLarge,
    super.key,
  });

  final Currency currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = currency.iconAsset;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.icon * size / 24),
        child: SizedBox.square(
          dimension: size,
          child: asset == null
              ? _Initials(currency: currency, size: size)
              : Image.asset(
                  asset,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) =>
                      _Initials(currency: currency, size: size),
                ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.currency, required this.size});

  final Currency currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final code = currency.code;
    return ColoredBox(
      color: colors.primary,
      child: Center(
        child: Text(
          code.length > 2 ? code.substring(0, 2) : code,
          style: AppTypography.label.copyWith(
            color: colors.onPrimary,
            fontSize: size * 0.42,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

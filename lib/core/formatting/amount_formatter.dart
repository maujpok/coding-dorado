import 'package:decimal/decimal.dart';

/// Formatea y parsea montos sin pasar por `double`.
///
/// El formato sigue al diseño: punto decimal y coma de miles ("3,300.00").
abstract final class AmountFormatter {
  static final Decimal _hundred = Decimal.fromInt(100);

  /// "1234.5" → "1,234.50". Con [truncate] corta en lugar de redondear, para
  /// no mostrar más de lo que el usuario recibirá.
  static String format(
    Decimal value, {
    int fractionDigits = 2,
    bool truncate = false,
  }) {
    final scaled = truncate
        ? value.truncate(scale: fractionDigits)
        : value.round(scale: fractionDigits);
    final fixed = scaled.abs().toStringAsFixed(fractionDigits);
    final parts = fixed.split('.');
    final grouped = _group(parts.first);
    final decimals = parts.length > 1 ? '.${parts[1]}' : '';
    final sign = scaled < Decimal.zero ? '-' : '';
    return '$sign$grouped$decimals';
  }

  /// "+1.25", "-0.10", "0.00".
  static String signed(
    Decimal value, {
    int fractionDigits = 2,
    bool truncate = false,
  }) {
    final formatted = format(
      value,
      fractionDigits: fractionDigits,
      truncate: truncate,
    );
    final isZero = formatted.replaceAll(RegExp('[-0.,]'), '').isEmpty;
    if (isZero) return formatted.replaceFirst('-', '');
    return value > Decimal.zero ? '+$formatted' : formatted;
  }

  /// Porcentaje con signo: `0.01` (fracción) no; recibe el valor ya en
  /// porcentaje (`1.0` → "+1.00 %").
  static String percent(Decimal percentValue, {int fractionDigits = 2}) {
    return '${signed(percentValue, fractionDigits: fractionDigits)} %';
  }

  /// Fracción → porcentaje (`0.0125` → `1.25`).
  static Decimal toPercent(Decimal fraction) => fraction * _hundred;

  /// Texto del campo de monto → [Decimal]. Acepta coma o punto decimal.
  /// Devuelve `null` si está vacío, es inválido o no es mayor que cero.
  static Decimal? tryParsePositive(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (normalized.isEmpty || normalized == '.') return null;
    final value = Decimal.tryParse(normalized);
    if (value == null || value <= Decimal.zero) return null;
    return value;
  }

  static String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }
}

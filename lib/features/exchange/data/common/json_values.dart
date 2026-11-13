import 'package:decimal/decimal.dart';

/// Las APIs mandan montos como string ("1014.8292") o como número (1052).
/// Devuelve `null` si el valor no es un número válido.
Decimal? parseDecimal(Object? value) => switch (value) {
  final num number when number.isFinite => Decimal.tryParse(number.toString()),
  final String text => Decimal.tryParse(text.trim()),
  _ => null,
};

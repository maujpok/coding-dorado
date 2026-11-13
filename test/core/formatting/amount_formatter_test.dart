import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

Decimal d(String value) => Decimal.parse(value);

void main() {
  group('AmountFormatter.format', () {
    test('redondea a 2 decimales por defecto', () {
      expect(AmountFormatter.format(d('125')), '125.00');
      expect(AmountFormatter.format(d('25.005')), '25.01');
      expect(AmountFormatter.format(d('0')), '0.00');
    });

    test('trunca cuando se pide, sin errores de flotante', () {
      expect(AmountFormatter.format(d('33.33333333'), truncate: true), '33.33');
      expect(AmountFormatter.format(d('9.90099'), truncate: true), '9.90');
      expect(AmountFormatter.format(d('0.1') + d('0.2')), '0.30');
    });

    test('agrupa miles con coma', () {
      expect(AmountFormatter.format(d('3300')), '3,300.00');
      expect(AmountFormatter.format(d('1803999.5')), '1,803,999.50');
      expect(AmountFormatter.format(d('999')), '999.00');
      expect(AmountFormatter.format(d('1000')), '1,000.00');
    });

    test('valores grandes y negativos', () {
      expect(
        AmountFormatter.format(d('12345678901234567890.129')),
        '12,345,678,901,234,567,890.13',
      );
      expect(AmountFormatter.format(d('-1234.5')), '-1,234.50');
    });

    test('respeta fractionDigits', () {
      expect(AmountFormatter.format(d('3.4542'), fractionDigits: 4), '3.4542');
      expect(AmountFormatter.format(d('10'), fractionDigits: 0), '10');
    });
  });

  group('AmountFormatter.signed y percent', () {
    test('agrega el signo', () {
      expect(AmountFormatter.signed(d('1.25')), '+1.25');
      expect(AmountFormatter.signed(d('-0.1')), '-0.10');
      expect(AmountFormatter.signed(d('0')), '0.00');
      expect(AmountFormatter.signed(d('-0.001')), '0.00');
    });

    test('porcentaje con signo y espacio', () {
      expect(AmountFormatter.percent(d('1')), '+1.00 %');
      expect(AmountFormatter.percent(d('-0.9901')), '-0.99 %');
      expect(AmountFormatter.toPercent(d('0.0125')), d('1.25'));
    });
  });

  group('AmountFormatter.tryParsePositive', () {
    test('acepta punto o coma decimal', () {
      expect(AmountFormatter.tryParsePositive('5'), d('5'));
      expect(AmountFormatter.tryParsePositive('5.50'), d('5.5'));
      expect(AmountFormatter.tryParsePositive(' 12,75 '), d('12.75'));
    });

    test('vacío, inválido, cero o negativo devuelven null', () {
      for (final input in ['', ' ', '.', 'abc', '0', '0.00', '-3']) {
        expect(AmountFormatter.tryParsePositive(input), isNull, reason: input);
      }
    });
  });
}

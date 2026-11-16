import 'dart:io';

import 'package:coding_dorado/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('ELDORADO_SOURCE y API_URL son opcionales', () {
      const config = AppConfig(
        eldoradoApiUrl: 'https://eldorado.test/api',
        criptoyaApiUrl: 'https://criptoya.test/api',
      );

      expect(config.eldoradoSource, EldoradoSource.prices);
      expect(config.orderbookApiUrl, isEmpty);
      expect(config.missingKeys, isEmpty);
      expect(config.ensureComplete, returnsNormally);
    });

    test('sin las URLs de las APIs (sin .env) falla con un mensaje claro', () {
      const config = AppConfig(eldoradoApiUrl: '', criptoyaApiUrl: '  ');

      expect(config.missingKeys, ['ELDORADO_API_URL', 'CRIPTOYA_API_URL']);
      expect(
        config.ensureComplete,
        throwsA(
          isA<MissingConfigException>()
              .having((e) => e.keys, 'keys', config.missingKeys)
              .having(
                (e) => e.toString(),
                'mensaje',
                contains('--dart-define-from-file=.env'),
              ),
        ),
      );
    });

    test('.env.example declara todas las claves y no trae URLs', () {
      final lines = File('.env.example')
          .readAsLinesSync()
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('#'));
      final entries = {
        for (final line in lines)
          line.substring(0, line.indexOf('=')): line.substring(
            line.indexOf('=') + 1,
          ),
      };

      expect(entries.keys, {
        'ELDORADO_API_URL',
        'CRIPTOYA_API_URL',
        'ELDORADO_SOURCE',
        'API_URL',
      });
      expect(entries.values.where((v) => v.contains('://')), isEmpty);
    });

    group('parseEldoradoSource', () {
      test('reconoce los valores válidos sin importar mayúsculas', () {
        expect(
          AppConfig.parseEldoradoSource('orderbook'),
          EldoradoSource.orderbook,
        );
        expect(
          AppConfig.parseEldoradoSource(' Prices '),
          EldoradoSource.prices,
        );
      });

      test('vacío o desconocido vuelve a prices', () {
        expect(AppConfig.parseEldoradoSource(''), EldoradoSource.prices);
        expect(AppConfig.parseEldoradoSource('otro'), EldoradoSource.prices);
      });
    });
  });
}

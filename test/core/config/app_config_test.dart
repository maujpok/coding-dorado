import 'package:coding_dorado/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('sin --dart-define usa los valores por defecto', () {
      expect(AppConfig.fromEnvironment(), const AppConfig.defaults());
    });

    test('los valores por defecto apuntan a las APIs reales', () {
      const config = AppConfig.defaults();

      expect(config.eldoradoApiUrl, 'https://api.eldorado.io/api');
      expect(config.criptoyaApiUrl, 'https://criptoya.com/api');
      expect(config.eldoradoSource, EldoradoSource.prices);
      expect(config.orderbookApiUrl, isEmpty);
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

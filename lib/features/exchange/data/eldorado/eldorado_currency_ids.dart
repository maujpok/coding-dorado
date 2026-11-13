import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';

/// IDs del catálogo de El Dorado (`GET …/stage/currencies`), que usa el API
/// de órdenes. Las fiat usan su código.
abstract final class EldoradoCurrencyIds {
  static const _cryptoIds = {
    'USDT': 'TATUM-TRON-USDT',
    'USDC': 'TATUM-MATIC-USDC',
  };

  static String of(Currency currency) =>
      _cryptoIds[currency.code] ?? currency.code;
}

import 'package:coding_dorado/features/exchange/domain/catalog/currency_catalog.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_pair.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_quote.dart';
import 'package:coding_dorado/features/exchange/domain/entities/exchange_rate.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';

import 'test_currencies.dart';

/// 10,000 USDT → ARS a 1,650.23 (la captura de El Dorado del usuario).
ExchangeQuote usdtToArsQuote({
  RateProvider provider = RateProvider.eldorado,
  String amount = '10000',
  String receive = '16502300',
}) => ExchangeQuote(
  provider: provider,
  pair: ExchangePair(from: CurrencyCatalog.usdt, to: CurrencyCatalog.ars),
  amount: dec(amount),
  rate: ExchangeRate(
    fiatPerCrypto: dec('1650.23'),
    estimatedTime: const Duration(minutes: 10),
  ),
  receiveAmount: dec(receive),
);

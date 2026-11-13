import 'package:coding_dorado/core/error/failure.dart';
import 'package:coding_dorado/core/formatting/amount_formatter.dart';
import 'package:coding_dorado/features/exchange/domain/entities/currency.dart';
import 'package:coding_dorado/features/exchange/domain/entities/rate_provider.dart';
import 'package:coding_dorado/l10n/gen/app_localizations.dart';

/// Textos que dependen de entidades del dominio.
extension ExchangeL10n on AppLocalizations {
  String providerName(RateProvider provider) => switch (provider) {
    RateProvider.eldorado => providerEldorado,
    RateProvider.criptoya => providerCriptoya,
  };

  String pickerTitle(CurrencyType type) => switch (type) {
    CurrencyType.fiat => pickerTitleFiat,
    CurrencyType.crypto => pickerTitleCrypto,
  };

  /// "Bolívares (Bs)".
  String currencyDescription(Currency currency) =>
      currencySubtitle(currency.name, currency.symbol);

  /// Mensaje para un [Failure]. [from] es la moneda del monto (para el
  /// mínimo) y [provider], la fuente de la pestaña.
  String failureMessage(
    Failure failure, {
    required RateProvider provider,
    required Currency from,
  }) => switch (failure) {
    NetworkFailure() => errorNetwork,
    TimeoutFailure() => errorTimeout,
    ServerFailure(isRateLimited: true) => errorRateLimited,
    ServerFailure() || InvalidRequestFailure() => errorServer,
    PairUnavailableFailure() => errorPairUnavailable(providerName(provider)),
    NoOffersFailure() => errorNoOffers,
    ParsingFailure() => errorParsing,
    InvalidRateFailure() => errorServer,
    BelowMinimumFailure(:final minAmount) => errorBelowMinimum(
      AmountFormatter.format(minAmount),
      from.code,
    ),
    UnknownFailure() => errorUnknown,
  };
}

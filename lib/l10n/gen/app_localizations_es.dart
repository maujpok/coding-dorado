// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calculadora de cambio';

  @override
  String get providerEldorado => 'El Dorado';

  @override
  String get providerCriptoya => 'CriptoYa';

  @override
  String get providerTabsLabel => 'Fuente de la tasa';

  @override
  String get haveLabel => 'TENGO';

  @override
  String get wantLabel => 'QUIERO';

  @override
  String selectorSemantics(String side, String code) {
    return '$side: $code. Cambiar moneda';
  }

  @override
  String get swapSemantics => 'Invertir monedas';

  @override
  String amountSemantics(String code) {
    return 'Monto a cambiar en $code';
  }

  @override
  String get amountHint => '0.00';

  @override
  String get estimatedRateLabel => 'Tasa estimada';

  @override
  String get receiveLabel => 'Recibirás';

  @override
  String get estimatedTimeLabel => 'Tiempo estimado';

  @override
  String get minutesUnit => 'Min';

  @override
  String approxValueSemantics(String label, String value, String unit) {
    return '$label: aproximadamente $value $unit';
  }

  @override
  String get emptyValue => '—';

  @override
  String get exchangeButton => 'Cambiar';

  @override
  String exchangeConfirmation(
    String amount,
    String from,
    String receive,
    String to,
  ) {
    return 'Simulación: cambiarías $amount $from por ≈ $receive $to.';
  }

  @override
  String get pickerTitleFiat => 'FIAT';

  @override
  String get pickerTitleCrypto => 'Cripto';

  @override
  String currencySubtitle(String name, String symbol) {
    return '$name ($symbol)';
  }

  @override
  String get unavailableLabel => 'No disponible';

  @override
  String get sourceEldorado => 'Fuente: El Dorado · tasa indicativa';

  @override
  String sourceCriptoya(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mediana de $count exchanges P2P',
      one: '1 exchange P2P',
    );
    return 'Fuente: CriptoYa · $_temp0';
  }

  @override
  String get sourceCriptoyaGeneric =>
      'Fuente: CriptoYa · mediana de exchanges P2P';

  @override
  String get errorNetwork => 'Sin conexión. Revisa tu internet.';

  @override
  String get errorTimeout => 'El servicio tardó demasiado. Intenta de nuevo.';

  @override
  String get errorRateLimited => 'Demasiadas consultas. Espera un momento.';

  @override
  String get errorServer => 'No pudimos obtener la tasa.';

  @override
  String errorPairUnavailable(String provider) {
    return 'Este par no está disponible en $provider.';
  }

  @override
  String get errorNoOffers =>
      'No hay ofertas para este par. Prueba con otro par o monto.';

  @override
  String get errorParsing => 'Recibimos una respuesta inesperada.';

  @override
  String errorBelowMinimum(String amount, String code) {
    return 'Mínimo $amount $code';
  }

  @override
  String get errorUnknown => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get retryAction => 'Reintentar';

  @override
  String get chooseCurrencyAction => 'Elegir otra moneda';

  @override
  String viewInProviderAction(String provider) {
    return 'Ver en $provider';
  }

  @override
  String get mockBanner => 'MOCK';
}

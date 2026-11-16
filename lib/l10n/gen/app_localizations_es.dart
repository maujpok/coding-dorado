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
  String get calculatorTitle => 'Calculadora';

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
  String valueSemantics(String label, String value, String unit) {
    return '$label: $value $unit';
  }

  @override
  String get emptyValue => '—';

  @override
  String get exchangeButton => 'Simular';

  @override
  String get confirmTitle => 'Confirma tu cambio';

  @override
  String get confirmSubtitle =>
      'Revisa los datos antes de confirmar. Puedes editar el monto y las monedas.';

  @override
  String get confirmFromLabel => 'Moneda que entregas';

  @override
  String get confirmToLabel => 'Moneda que recibes';

  @override
  String get confirmAmountLabel => 'Cantidad';

  @override
  String get swapAction => 'Invertir';

  @override
  String get sourceLabel => 'Fuente';

  @override
  String get confirmAction => 'Confirmar';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get simulationNote => 'Operación simulada: no se mueve dinero real.';

  @override
  String exchangeSubject(String amount, String from, String to) {
    return '$amount $from a $to';
  }

  @override
  String get processingTitle => 'Procesando tu cambio';

  @override
  String get processingStepValidate => 'Validando la cotización';

  @override
  String get processingStepExchange => 'Ejecutando el cambio';

  @override
  String get processingStepConfirm => 'Confirmando la transacción';

  @override
  String processingStepDone(String step) {
    return '$step: listo';
  }

  @override
  String processingStepActive(String step) {
    return '$step: en curso';
  }

  @override
  String processingStepPending(String step) {
    return '$step: pendiente';
  }

  @override
  String get processingFailedTitle => 'No pudimos completar el cambio';

  @override
  String get backAction => 'Volver';

  @override
  String get successTitle => '¡Cambio exitoso!';

  @override
  String get successSubtitle => 'Tu transacción se completó correctamente.';

  @override
  String get receiptReceived => 'Recibiste';

  @override
  String receiptSent(String amount, String code) {
    return 'por $amount $code';
  }

  @override
  String get receiptRate => 'Tasa';

  @override
  String receiptRateValue(String crypto, String rate, String fiat) {
    return '1 $crypto = $rate $fiat';
  }

  @override
  String get receiptDate => 'Fecha';

  @override
  String get receiptTime => 'Hora';

  @override
  String get receiptId => 'ID de transacción';

  @override
  String get receiptStatus => 'Estado';

  @override
  String get receiptStatusCompleted => 'Completada';

  @override
  String get copyIdAction => 'Copiar ID';

  @override
  String get idCopied => 'ID copiado';

  @override
  String get successDone => 'Volver al inicio';

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
  String get compareAction => 'Comparar cotizaciones';

  @override
  String get compareTitle => 'Comparar cotizaciones';

  @override
  String compareSubject(String amount, String from, String to) {
    return '$amount $from a $to';
  }

  @override
  String get compareRefresh => 'Actualizar cotizaciones';

  @override
  String get compareBestBadge => 'Mejor opción';

  @override
  String compareRate(String rate, String fiat) {
    return 'Tasa ≈ $rate $fiat';
  }

  @override
  String compareMinimum(String amount, String code) {
    return 'Mínimo $amount $code';
  }

  @override
  String get compareSourceEldorado => 'Libro P2P de El Dorado';

  @override
  String compareSourceCriptoya(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mediana de $count exchanges P2P',
      one: '1 exchange P2P',
    );
    return '$_temp0';
  }

  @override
  String compareUse(String provider) {
    return 'Usar $provider';
  }

  @override
  String compareWinner(
    String provider,
    String difference,
    String code,
    String percent,
  ) {
    return 'Con $provider recibes $difference $code ($percent)';
  }

  @override
  String get compareTie => 'Ambos ofrecen la misma cotización.';

  @override
  String compareOnlyOne(String provider) {
    return 'Solo $provider tiene cotización para este par.';
  }

  @override
  String get compareNone => 'Ningún proveedor tiene cotización para este par.';

  @override
  String get compareFootnote =>
      'El Dorado muestra el precio de su propio libro P2P y CriptoYa la mediana de varios exchanges. Ambas tasas son indicativas.';

  @override
  String get mockBanner => 'MOCK';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Título de la app.
  ///
  /// In es, this message translates to:
  /// **'Calculadora de cambio'**
  String get appTitle;

  /// Título encima de la tarjeta de la calculadora.
  ///
  /// In es, this message translates to:
  /// **'Calculadora'**
  String get calculatorTitle;

  /// No description provided for @providerEldorado.
  ///
  /// In es, this message translates to:
  /// **'El Dorado'**
  String get providerEldorado;

  /// No description provided for @providerCriptoya.
  ///
  /// In es, this message translates to:
  /// **'CriptoYa'**
  String get providerCriptoya;

  /// Etiqueta de accesibilidad del selector de pestañas.
  ///
  /// In es, this message translates to:
  /// **'Fuente de la tasa'**
  String get providerTabsLabel;

  /// No description provided for @haveLabel.
  ///
  /// In es, this message translates to:
  /// **'TENGO'**
  String get haveLabel;

  /// No description provided for @wantLabel.
  ///
  /// In es, this message translates to:
  /// **'QUIERO'**
  String get wantLabel;

  /// No description provided for @selectorSemantics.
  ///
  /// In es, this message translates to:
  /// **'{side}: {code}. Cambiar moneda'**
  String selectorSemantics(String side, String code);

  /// No description provided for @swapSemantics.
  ///
  /// In es, this message translates to:
  /// **'Invertir monedas'**
  String get swapSemantics;

  /// No description provided for @amountSemantics.
  ///
  /// In es, this message translates to:
  /// **'Monto a cambiar en {code}'**
  String amountSemantics(String code);

  /// No description provided for @amountHint.
  ///
  /// In es, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @estimatedRateLabel.
  ///
  /// In es, this message translates to:
  /// **'Tasa estimada'**
  String get estimatedRateLabel;

  /// No description provided for @receiveLabel.
  ///
  /// In es, this message translates to:
  /// **'Recibirás'**
  String get receiveLabel;

  /// No description provided for @estimatedTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo estimado'**
  String get estimatedTimeLabel;

  /// No description provided for @minutesUnit.
  ///
  /// In es, this message translates to:
  /// **'Min'**
  String get minutesUnit;

  /// No description provided for @approxValueSemantics.
  ///
  /// In es, this message translates to:
  /// **'{label}: aproximadamente {value} {unit}'**
  String approxValueSemantics(String label, String value, String unit);

  /// No description provided for @valueSemantics.
  ///
  /// In es, this message translates to:
  /// **'{label}: {value} {unit}'**
  String valueSemantics(String label, String value, String unit);

  /// No description provided for @emptyValue.
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get emptyValue;

  /// No description provided for @exchangeButton.
  ///
  /// In es, this message translates to:
  /// **'Simular'**
  String get exchangeButton;

  /// No description provided for @confirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu cambio'**
  String get confirmTitle;

  /// No description provided for @confirmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos antes de confirmar. Puedes editar el monto y las monedas.'**
  String get confirmSubtitle;

  /// No description provided for @confirmFromLabel.
  ///
  /// In es, this message translates to:
  /// **'Moneda que entregas'**
  String get confirmFromLabel;

  /// No description provided for @confirmToLabel.
  ///
  /// In es, this message translates to:
  /// **'Moneda que recibes'**
  String get confirmToLabel;

  /// No description provided for @confirmAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get confirmAmountLabel;

  /// No description provided for @swapAction.
  ///
  /// In es, this message translates to:
  /// **'Invertir'**
  String get swapAction;

  /// No description provided for @sourceLabel.
  ///
  /// In es, this message translates to:
  /// **'Fuente'**
  String get sourceLabel;

  /// No description provided for @confirmAction.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirmAction;

  /// No description provided for @cancelAction.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelAction;

  /// No description provided for @simulationNote.
  ///
  /// In es, this message translates to:
  /// **'Operación simulada: no se mueve dinero real.'**
  String get simulationNote;

  /// No description provided for @exchangeSubject.
  ///
  /// In es, this message translates to:
  /// **'{amount} {from} a {to}'**
  String exchangeSubject(String amount, String from, String to);

  /// No description provided for @processingTitle.
  ///
  /// In es, this message translates to:
  /// **'Procesando tu cambio'**
  String get processingTitle;

  /// No description provided for @processingStepValidate.
  ///
  /// In es, this message translates to:
  /// **'Validando la cotización'**
  String get processingStepValidate;

  /// No description provided for @processingStepExchange.
  ///
  /// In es, this message translates to:
  /// **'Ejecutando el cambio'**
  String get processingStepExchange;

  /// No description provided for @processingStepConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmando la transacción'**
  String get processingStepConfirm;

  /// No description provided for @processingStepDone.
  ///
  /// In es, this message translates to:
  /// **'{step}: listo'**
  String processingStepDone(String step);

  /// No description provided for @processingStepActive.
  ///
  /// In es, this message translates to:
  /// **'{step}: en curso'**
  String processingStepActive(String step);

  /// No description provided for @processingStepPending.
  ///
  /// In es, this message translates to:
  /// **'{step}: pendiente'**
  String processingStepPending(String step);

  /// No description provided for @processingFailedTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar el cambio'**
  String get processingFailedTitle;

  /// No description provided for @backAction.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get backAction;

  /// No description provided for @successTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Cambio exitoso!'**
  String get successTitle;

  /// No description provided for @successSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu transacción se completó correctamente.'**
  String get successSubtitle;

  /// No description provided for @receiptReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibiste'**
  String get receiptReceived;

  /// No description provided for @receiptSent.
  ///
  /// In es, this message translates to:
  /// **'por {amount} {code}'**
  String receiptSent(String amount, String code);

  /// No description provided for @receiptRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa'**
  String get receiptRate;

  /// No description provided for @receiptRateValue.
  ///
  /// In es, this message translates to:
  /// **'1 {crypto} = {rate} {fiat}'**
  String receiptRateValue(String crypto, String rate, String fiat);

  /// No description provided for @receiptDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get receiptDate;

  /// No description provided for @receiptTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get receiptTime;

  /// No description provided for @receiptId.
  ///
  /// In es, this message translates to:
  /// **'ID de transacción'**
  String get receiptId;

  /// No description provided for @receiptStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get receiptStatus;

  /// No description provided for @receiptStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get receiptStatusCompleted;

  /// No description provided for @copyIdAction.
  ///
  /// In es, this message translates to:
  /// **'Copiar ID'**
  String get copyIdAction;

  /// No description provided for @idCopied.
  ///
  /// In es, this message translates to:
  /// **'ID copiado'**
  String get idCopied;

  /// No description provided for @successDone.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get successDone;

  /// No description provided for @pickerTitleFiat.
  ///
  /// In es, this message translates to:
  /// **'FIAT'**
  String get pickerTitleFiat;

  /// No description provided for @pickerTitleCrypto.
  ///
  /// In es, this message translates to:
  /// **'Cripto'**
  String get pickerTitleCrypto;

  /// No description provided for @currencySubtitle.
  ///
  /// In es, this message translates to:
  /// **'{name} ({symbol})'**
  String currencySubtitle(String name, String symbol);

  /// No description provided for @sourceEldorado.
  ///
  /// In es, this message translates to:
  /// **'Fuente: El Dorado · tasa indicativa'**
  String get sourceEldorado;

  /// No description provided for @sourceCriptoya.
  ///
  /// In es, this message translates to:
  /// **'Fuente: CriptoYa · {count, plural, =1{1 exchange P2P} other{mediana de {count} exchanges P2P}}'**
  String sourceCriptoya(int count);

  /// No description provided for @sourceCriptoyaGeneric.
  ///
  /// In es, this message translates to:
  /// **'Fuente: CriptoYa · mediana de exchanges P2P'**
  String get sourceCriptoyaGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In es, this message translates to:
  /// **'El servicio tardó demasiado. Intenta de nuevo.'**
  String get errorTimeout;

  /// No description provided for @errorRateLimited.
  ///
  /// In es, this message translates to:
  /// **'Demasiadas consultas. Espera un momento.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In es, this message translates to:
  /// **'No pudimos obtener la tasa.'**
  String get errorServer;

  /// No description provided for @errorPairUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Este par no está disponible en {provider}.'**
  String errorPairUnavailable(String provider);

  /// No description provided for @errorNoOffers.
  ///
  /// In es, this message translates to:
  /// **'No hay ofertas para este par. Prueba con otro par o monto.'**
  String get errorNoOffers;

  /// No description provided for @errorParsing.
  ///
  /// In es, this message translates to:
  /// **'Recibimos una respuesta inesperada.'**
  String get errorParsing;

  /// No description provided for @errorBelowMinimum.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {amount} {code}'**
  String errorBelowMinimum(String amount, String code);

  /// No description provided for @errorUnknown.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Intenta de nuevo.'**
  String get errorUnknown;

  /// No description provided for @retryAction.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retryAction;

  /// No description provided for @chooseCurrencyAction.
  ///
  /// In es, this message translates to:
  /// **'Elegir otra moneda'**
  String get chooseCurrencyAction;

  /// No description provided for @viewInProviderAction.
  ///
  /// In es, this message translates to:
  /// **'Ver en {provider}'**
  String viewInProviderAction(String provider);

  /// No description provided for @compareAction.
  ///
  /// In es, this message translates to:
  /// **'Comparar cotizaciones'**
  String get compareAction;

  /// No description provided for @compareTitle.
  ///
  /// In es, this message translates to:
  /// **'Comparar cotizaciones'**
  String get compareTitle;

  /// No description provided for @compareSubject.
  ///
  /// In es, this message translates to:
  /// **'{amount} {from} a {to}'**
  String compareSubject(String amount, String from, String to);

  /// No description provided for @compareRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar cotizaciones'**
  String get compareRefresh;

  /// No description provided for @compareBestBadge.
  ///
  /// In es, this message translates to:
  /// **'Mejor opción'**
  String get compareBestBadge;

  /// No description provided for @compareRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa ≈ {rate} {fiat}'**
  String compareRate(String rate, String fiat);

  /// No description provided for @compareMinimum.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {amount} {code}'**
  String compareMinimum(String amount, String code);

  /// No description provided for @compareSourceEldorado.
  ///
  /// In es, this message translates to:
  /// **'Libro P2P de El Dorado'**
  String get compareSourceEldorado;

  /// No description provided for @compareSourceCriptoya.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 exchange P2P} other{Mediana de {count} exchanges P2P}}'**
  String compareSourceCriptoya(int count);

  /// No description provided for @compareUse.
  ///
  /// In es, this message translates to:
  /// **'Usar {provider}'**
  String compareUse(String provider);

  /// No description provided for @compareWinner.
  ///
  /// In es, this message translates to:
  /// **'Con {provider} recibes {difference} {code} ({percent})'**
  String compareWinner(
    String provider,
    String difference,
    String code,
    String percent,
  );

  /// No description provided for @compareTie.
  ///
  /// In es, this message translates to:
  /// **'Ambos ofrecen la misma cotización.'**
  String get compareTie;

  /// No description provided for @compareOnlyOne.
  ///
  /// In es, this message translates to:
  /// **'Solo {provider} tiene cotización para este par.'**
  String compareOnlyOne(String provider);

  /// No description provided for @compareNone.
  ///
  /// In es, this message translates to:
  /// **'Ningún proveedor tiene cotización para este par.'**
  String get compareNone;

  /// No description provided for @compareFootnote.
  ///
  /// In es, this message translates to:
  /// **'El Dorado muestra el precio de su propio libro P2P y CriptoYa la mediana de varios exchanges. Ambas tasas son indicativas.'**
  String get compareFootnote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

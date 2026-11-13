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

  /// No description provided for @emptyValue.
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get emptyValue;

  /// No description provided for @exchangeButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get exchangeButton;

  /// No description provided for @exchangeConfirmation.
  ///
  /// In es, this message translates to:
  /// **'Simulación: cambiarías {amount} {from} por ≈ {receive} {to}.'**
  String exchangeConfirmation(
    String amount,
    String from,
    String receive,
    String to,
  );

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

  /// No description provided for @unavailableLabel.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get unavailableLabel;

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

  /// No description provided for @mockBanner.
  ///
  /// In es, this message translates to:
  /// **'MOCK'**
  String get mockBanner;
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

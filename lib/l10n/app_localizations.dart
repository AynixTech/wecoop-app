import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'WECOOP'**
  String get appTitle;

  /// No description provided for @hello.
  ///
  /// In it, this message translates to:
  /// **'Ciao'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In it, this message translates to:
  /// **'Benvenuta su WECOOP! Esplora eventi, servizi e progetti vicino a te.'**
  String get welcome;

  /// No description provided for @user.
  ///
  /// In it, this message translates to:
  /// **'Utente'**
  String get user;

  /// No description provided for @profile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In it, this message translates to:
  /// **'Calendario'**
  String get calendar;

  /// No description provided for @projects.
  ///
  /// In it, this message translates to:
  /// **'Progetti'**
  String get projects;

  /// No description provided for @services.
  ///
  /// In it, this message translates to:
  /// **'Servizi'**
  String get services;

  /// No description provided for @notifications.
  ///
  /// In it, this message translates to:
  /// **'Notifiche'**
  String get notifications;

  /// No description provided for @login.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In it, this message translates to:
  /// **'Logout effettuato'**
  String get logoutConfirm;

  /// No description provided for @email.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberPassword.
  ///
  /// In it, this message translates to:
  /// **'Ricorda password'**
  String get rememberPassword;

  /// No description provided for @loginButton.
  ///
  /// In it, this message translates to:
  /// **'ACCEDI'**
  String get loginButton;

  /// No description provided for @loginError.
  ///
  /// In it, this message translates to:
  /// **'Login fallito'**
  String get loginError;

  /// No description provided for @networkError.
  ///
  /// In it, this message translates to:
  /// **'Errore di rete'**
  String get networkError;

  /// No description provided for @emailNotAvailable.
  ///
  /// In it, this message translates to:
  /// **'email non disponibile'**
  String get emailNotAvailable;

  /// No description provided for @memberCard.
  ///
  /// In it, this message translates to:
  /// **'Tessera Socio WECOOP'**
  String get memberCard;

  /// No description provided for @cardNumber.
  ///
  /// In it, this message translates to:
  /// **'N° Tessera'**
  String get cardNumber;

  /// No description provided for @cardNotAvailable.
  ///
  /// In it, this message translates to:
  /// **'Tessera non disponibile'**
  String get cardNotAvailable;

  /// No description provided for @openDigitalCard.
  ///
  /// In it, this message translates to:
  /// **'Apri tessera digitale'**
  String get openDigitalCard;

  /// No description provided for @preferences.
  ///
  /// In it, this message translates to:
  /// **'Preferenze'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get language;

  /// No description provided for @areaOfInterest.
  ///
  /// In it, this message translates to:
  /// **'Area di interesse'**
  String get areaOfInterest;

  /// No description provided for @participationHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico partecipazioni'**
  String get participationHistory;

  /// No description provided for @italian.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @english.
  ///
  /// In it, this message translates to:
  /// **'Inglese'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In it, this message translates to:
  /// **'Spagnolo'**
  String get spanish;

  /// No description provided for @arabic.
  ///
  /// In it, this message translates to:
  /// **'Arabo'**
  String get arabic;

  /// No description provided for @culture.
  ///
  /// In it, this message translates to:
  /// **'Cultura'**
  String get culture;

  /// No description provided for @sport.
  ///
  /// In it, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @training.
  ///
  /// In it, this message translates to:
  /// **'Formazione'**
  String get training;

  /// No description provided for @volunteering.
  ///
  /// In it, this message translates to:
  /// **'Volontariato'**
  String get volunteering;

  /// No description provided for @socialServices.
  ///
  /// In it, this message translates to:
  /// **'Servizi sociali'**
  String get socialServices;

  /// No description provided for @servicesTitle.
  ///
  /// In it, this message translates to:
  /// **'🛠️ Servizi'**
  String get servicesTitle;

  /// No description provided for @welcomeService.
  ///
  /// In it, this message translates to:
  /// **'Accoglienza'**
  String get welcomeService;

  /// No description provided for @taxMediationService.
  ///
  /// In it, this message translates to:
  /// **'Mediazione fiscale'**
  String get taxMediationService;

  /// No description provided for @accountingService.
  ///
  /// In it, this message translates to:
  /// **'Supporto contabile'**
  String get accountingService;

  /// No description provided for @seeAll.
  ///
  /// In it, this message translates to:
  /// **'Vedi tutti'**
  String get seeAll;

  /// No description provided for @upcomingEvents.
  ///
  /// In it, this message translates to:
  /// **'📅 Prossimi eventi'**
  String get upcomingEvents;

  /// No description provided for @activeProjects.
  ///
  /// In it, this message translates to:
  /// **'🤝 Progetti attivi'**
  String get activeProjects;

  /// No description provided for @latestNews.
  ///
  /// In it, this message translates to:
  /// **'📰 Ultime notizie'**
  String get latestNews;

  /// No description provided for @quickAccess.
  ///
  /// In it, this message translates to:
  /// **'⚡ Accesso rapido'**
  String get quickAccess;

  /// No description provided for @eventInterculturalDinner.
  ///
  /// In it, this message translates to:
  /// **'Cena Interculturale'**
  String get eventInterculturalDinner;

  /// No description provided for @eventSewingLab.
  ///
  /// In it, this message translates to:
  /// **'Laboratorio di cucito'**
  String get eventSewingLab;

  /// No description provided for @eventItalianCourse.
  ///
  /// In it, this message translates to:
  /// **'Corso di italiano'**
  String get eventItalianCourse;

  /// No description provided for @projectMafalda.
  ///
  /// In it, this message translates to:
  /// **'MAFALDA'**
  String get projectMafalda;

  /// No description provided for @projectMafaldaDesc.
  ///
  /// In it, this message translates to:
  /// **'Giovani e inclusione'**
  String get projectMafaldaDesc;

  /// No description provided for @projectWomentor.
  ///
  /// In it, this message translates to:
  /// **'WOMENTOR'**
  String get projectWomentor;

  /// No description provided for @projectWomentorDesc.
  ///
  /// In it, this message translates to:
  /// **'Mentoring tra donne'**
  String get projectWomentorDesc;

  /// No description provided for @projectSportunity.
  ///
  /// In it, this message translates to:
  /// **'SPORTUNITY'**
  String get projectSportunity;

  /// No description provided for @projectSportunityDesc.
  ///
  /// In it, this message translates to:
  /// **'Sport e comunità'**
  String get projectSportunityDesc;

  /// No description provided for @loading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento...'**
  String get loading;

  /// No description provided for @noNews.
  ///
  /// In it, this message translates to:
  /// **'Nessuna notizia disponibile'**
  String get noNews;

  /// No description provided for @refresh.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get refresh;

  /// No description provided for @myRequests.
  ///
  /// In it, this message translates to:
  /// **'Le Mie Richieste'**
  String get myRequests;

  /// No description provided for @allRequests.
  ///
  /// In it, this message translates to:
  /// **'Tutte'**
  String get allRequests;

  /// No description provided for @pendingPayment.
  ///
  /// In it, this message translates to:
  /// **'In attesa pagamento'**
  String get pendingPayment;

  /// No description provided for @processing.
  ///
  /// In it, this message translates to:
  /// **'In lavorazione'**
  String get processing;

  /// No description provided for @completed.
  ///
  /// In it, this message translates to:
  /// **'Completate'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In it, this message translates to:
  /// **'Annullate'**
  String get cancelled;

  /// No description provided for @requestDetails.
  ///
  /// In it, this message translates to:
  /// **'Dettaglio Richiesta'**
  String get requestDetails;

  /// No description provided for @service.
  ///
  /// In it, this message translates to:
  /// **'Servizio'**
  String get service;

  /// No description provided for @description.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get description;

  /// No description provided for @requestDate.
  ///
  /// In it, this message translates to:
  /// **'Data Richiesta'**
  String get requestDate;

  /// No description provided for @status.
  ///
  /// In it, this message translates to:
  /// **'Stato'**
  String get status;

  /// No description provided for @paymentInfo.
  ///
  /// In it, this message translates to:
  /// **'Informazioni Pagamento'**
  String get paymentInfo;

  /// No description provided for @paymentStatus.
  ///
  /// In it, this message translates to:
  /// **'Stato Pagamento'**
  String get paymentStatus;

  /// No description provided for @paid.
  ///
  /// In it, this message translates to:
  /// **'Pagato'**
  String get paid;

  /// No description provided for @notPaid.
  ///
  /// In it, this message translates to:
  /// **'Non pagato'**
  String get notPaid;

  /// No description provided for @paymentMethod.
  ///
  /// In it, this message translates to:
  /// **'Metodo'**
  String get paymentMethod;

  /// No description provided for @paymentDate.
  ///
  /// In it, this message translates to:
  /// **'Data Pagamento'**
  String get paymentDate;

  /// No description provided for @transactionId.
  ///
  /// In it, this message translates to:
  /// **'ID Transazione'**
  String get transactionId;

  /// No description provided for @amount.
  ///
  /// In it, this message translates to:
  /// **'Importo'**
  String get amount;

  /// No description provided for @payNow.
  ///
  /// In it, this message translates to:
  /// **'Paga ora'**
  String get payNow;

  /// No description provided for @cannotOpenPaymentLink.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il link di pagamento'**
  String get cannotOpenPaymentLink;

  /// No description provided for @noRequestsForDay.
  ///
  /// In it, this message translates to:
  /// **'Nessuna richiesta per questo giorno'**
  String get noRequestsForDay;

  /// No description provided for @noRequests.
  ///
  /// In it, this message translates to:
  /// **'Nessuna richiesta trovata'**
  String get noRequests;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;
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
      <String>['en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

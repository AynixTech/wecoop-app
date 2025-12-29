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
  /// **'Esplora eventi, servizi e progetti vicino a te.'**
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
  /// **'Richieste'**
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

  /// No description provided for @loginToAccessServices.
  ///
  /// In it, this message translates to:
  /// **'Effettua il login per accedere a tutti i servizi riservati ai soci.'**
  String get loginToAccessServices;

  /// No description provided for @membershipPendingApproval.
  ///
  /// In it, this message translates to:
  /// **'La tua richiesta di adesione come socio è in fase di approvazione.'**
  String get membershipPendingApproval;

  /// No description provided for @confirmationWithin24to48Hours.
  ///
  /// In it, this message translates to:
  /// **'Riceverai una conferma via email entro 24-48 ore.'**
  String get confirmationWithin24to48Hours;

  /// No description provided for @onceApprovedAccessAllServices.
  ///
  /// In it, this message translates to:
  /// **'Una volta approvata, potrai accedere a tutti i servizi.'**
  String get onceApprovedAccessAllServices;

  /// No description provided for @toAccessServicesBecomeMember.
  ///
  /// In it, this message translates to:
  /// **'Per accedere ai servizi di {serviceName} devi essere socio di WECOOP.'**
  String toAccessServicesBecomeMember(Object serviceName);

  /// No description provided for @becomeMemberToAccess.
  ///
  /// In it, this message translates to:
  /// **'Diventa socio per accedere a:'**
  String get becomeMemberToAccess;

  /// No description provided for @whyBecomeMember.
  ///
  /// In it, this message translates to:
  /// **'Perché diventare socio?'**
  String get whyBecomeMember;

  /// No description provided for @operationCompleted.
  ///
  /// In it, this message translates to:
  /// **'Operazione completata'**
  String get operationCompleted;

  /// No description provided for @fiscalCodeMustBe16Chars.
  ///
  /// In it, this message translates to:
  /// **'Il codice fiscale deve essere di 16 caratteri'**
  String get fiscalCodeMustBe16Chars;

  /// No description provided for @birthPlace.
  ///
  /// In it, this message translates to:
  /// **'Luogo di Nascita'**
  String get birthPlace;

  /// No description provided for @invalidPostalCode.
  ///
  /// In it, this message translates to:
  /// **'CAP non valido'**
  String get invalidPostalCode;

  /// No description provided for @invalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Email non valida'**
  String get invalidEmail;

  /// No description provided for @fillFollowingFields.
  ///
  /// In it, this message translates to:
  /// **'Compila i seguenti campi'**
  String get fillFollowingFields;

  /// No description provided for @sendingError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'invio'**
  String get sendingError;

  /// No description provided for @politicalAsylum.
  ///
  /// In it, this message translates to:
  /// **'Asilo Politico'**
  String get politicalAsylum;

  /// No description provided for @internationalProtectionRequest.
  ///
  /// In it, this message translates to:
  /// **'La richiesta di protezione internazionale è un processo delicato. Ti aiuteremo a preparare la documentazione.'**
  String get internationalProtectionRequest;

  /// No description provided for @internationalProtection.
  ///
  /// In it, this message translates to:
  /// **'Protezione Internazionale'**
  String get internationalProtection;

  /// No description provided for @fullName.
  ///
  /// In it, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @dateOfBirth.
  ///
  /// In it, this message translates to:
  /// **'Data di nascita'**
  String get dateOfBirth;

  /// No description provided for @countryOfOrigin.
  ///
  /// In it, this message translates to:
  /// **'Paese di origine'**
  String get countryOfOrigin;

  /// No description provided for @dateOfArrivalInItaly.
  ///
  /// In it, this message translates to:
  /// **'Data di arrivo in Italia'**
  String get dateOfArrivalInItaly;

  /// No description provided for @reasonForRequest.
  ///
  /// In it, this message translates to:
  /// **'Motivo della richiesta'**
  String get reasonForRequest;

  /// No description provided for @politicalPersecution.
  ///
  /// In it, this message translates to:
  /// **'Persecuzione politica'**
  String get politicalPersecution;

  /// No description provided for @religiousPersecution.
  ///
  /// In it, this message translates to:
  /// **'Persecuzione religiosa'**
  String get religiousPersecution;

  /// No description provided for @persecutionSexualOrientation.
  ///
  /// In it, this message translates to:
  /// **'Persecuzione per orientamento sessuale'**
  String get persecutionSexualOrientation;

  /// No description provided for @war.
  ///
  /// In it, this message translates to:
  /// **'Guerra'**
  String get war;

  /// No description provided for @other.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get other;

  /// No description provided for @situationDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione situazione'**
  String get situationDescription;

  /// No description provided for @hasFamilyInItaly.
  ///
  /// In it, this message translates to:
  /// **'Hai familiari in Italia?'**
  String get hasFamilyInItaly;

  /// No description provided for @additionalNotes.
  ///
  /// In it, this message translates to:
  /// **'Note aggiuntive'**
  String get additionalNotes;

  /// No description provided for @startRequest.
  ///
  /// In it, this message translates to:
  /// **'Inizia la richiesta'**
  String get startRequest;

  /// No description provided for @touristVisaRequest.
  ///
  /// In it, this message translates to:
  /// **'Richiesta Visa per Turismo'**
  String get touristVisaRequest;

  /// No description provided for @taxMediation.
  ///
  /// In it, this message translates to:
  /// **'Mediazione Fiscale'**
  String get taxMediation;

  /// No description provided for @accountingSupport.
  ///
  /// In it, this message translates to:
  /// **'Supporto Contabile'**
  String get accountingSupport;

  /// No description provided for @residencePermit.
  ///
  /// In it, this message translates to:
  /// **'Permesso di Soggiorno'**
  String get residencePermit;

  /// No description provided for @yes.
  ///
  /// In it, this message translates to:
  /// **'Sì'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In it, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @selectFiscalService.
  ///
  /// In it, this message translates to:
  /// **'Seleziona il servizio fiscale'**
  String get selectFiscalService;

  /// No description provided for @tax730Declaration.
  ///
  /// In it, this message translates to:
  /// **'730 - Dichiarazione dei Redditi'**
  String get tax730Declaration;

  /// No description provided for @tax730Description.
  ///
  /// In it, this message translates to:
  /// **'Compilazione modello 730 per dipendenti e pensionati'**
  String get tax730Description;

  /// No description provided for @individualPerson.
  ///
  /// In it, this message translates to:
  /// **'Persona Fisica'**
  String get individualPerson;

  /// No description provided for @individualPersonDescription.
  ///
  /// In it, this message translates to:
  /// **'Dichiarazione redditi per persone fisiche'**
  String get individualPersonDescription;

  /// No description provided for @taxpayerType.
  ///
  /// In it, this message translates to:
  /// **'Tipologia contribuente'**
  String get taxpayerType;

  /// No description provided for @employee.
  ///
  /// In it, this message translates to:
  /// **'Lavoratore dipendente'**
  String get employee;

  /// No description provided for @pensioner.
  ///
  /// In it, this message translates to:
  /// **'Pensionato'**
  String get pensioner;

  /// No description provided for @fiscalYear.
  ///
  /// In it, this message translates to:
  /// **'Anno fiscale'**
  String get fiscalYear;

  /// No description provided for @hasDeductibleExpenses.
  ///
  /// In it, this message translates to:
  /// **'Hai spese detraibili/deducibili?'**
  String get hasDeductibleExpenses;

  /// No description provided for @notesAndAdditionalInfo.
  ///
  /// In it, this message translates to:
  /// **'Note e informazioni aggiuntive'**
  String get notesAndAdditionalInfo;

  /// No description provided for @incomeType.
  ///
  /// In it, this message translates to:
  /// **'Tipologia di reddito'**
  String get incomeType;

  /// No description provided for @employedWork.
  ///
  /// In it, this message translates to:
  /// **'Lavoro dipendente'**
  String get employedWork;

  /// No description provided for @selfEmployed.
  ///
  /// In it, this message translates to:
  /// **'Lavoro autonomo'**
  String get selfEmployed;

  /// No description provided for @pension.
  ///
  /// In it, this message translates to:
  /// **'Pensione'**
  String get pension;

  /// No description provided for @capitalIncome.
  ///
  /// In it, this message translates to:
  /// **'Redditi da capitale'**
  String get capitalIncome;

  /// No description provided for @otherIncome.
  ///
  /// In it, this message translates to:
  /// **'Redditi diversi'**
  String get otherIncome;

  /// No description provided for @multipleTypes.
  ///
  /// In it, this message translates to:
  /// **'Più tipologie'**
  String get multipleTypes;

  /// No description provided for @hasProperties.
  ///
  /// In it, this message translates to:
  /// **'Hai immobili?'**
  String get hasProperties;

  /// No description provided for @detailsAndNotes.
  ///
  /// In it, this message translates to:
  /// **'Dettagli e note'**
  String get detailsAndNotes;

  /// No description provided for @youthCategory.
  ///
  /// In it, this message translates to:
  /// **'Giovani'**
  String get youthCategory;

  /// No description provided for @womenCategory.
  ///
  /// In it, this message translates to:
  /// **'Donne'**
  String get womenCategory;

  /// No description provided for @sportsCategory.
  ///
  /// In it, this message translates to:
  /// **'Sport'**
  String get sportsCategory;

  /// No description provided for @migrantsCategory.
  ///
  /// In it, this message translates to:
  /// **'Migranti'**
  String get migrantsCategory;

  /// No description provided for @projectDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione del progetto'**
  String get projectDescription;

  /// No description provided for @servicesOffered.
  ///
  /// In it, this message translates to:
  /// **'Servizi offerti'**
  String get servicesOffered;

  /// No description provided for @mafaldaDescription.
  ///
  /// In it, this message translates to:
  /// **'Progetto europeo dedicato ai giovani per lo sviluppo di competenze e opportunità di mobilità internazionale.'**
  String get mafaldaDescription;

  /// No description provided for @womentorDescription.
  ///
  /// In it, this message translates to:
  /// **'Programma di mentoring e networking intergenerazionale tra donne per la crescita personale e professionale.'**
  String get womentorDescription;

  /// No description provided for @sportunityDescription.
  ///
  /// In it, this message translates to:
  /// **'Integrazione sociale e inclusione attraverso lo sport e attività ricreative per tutta la comunità.'**
  String get sportunityDescription;

  /// No description provided for @passaparolaDescription.
  ///
  /// In it, this message translates to:
  /// **'Sportello dedicato ai migranti per supporto documentale, orientamento e integrazione sociale.'**
  String get passaparolaDescription;

  /// No description provided for @europeanProjectDesign.
  ///
  /// In it, this message translates to:
  /// **'Progettazione Europea'**
  String get europeanProjectDesign;

  /// No description provided for @europeanProjectDesignDesc.
  ///
  /// In it, this message translates to:
  /// **'Supporto nella progettazione e gestione di progetti finanziati dall\'Unione Europea'**
  String get europeanProjectDesignDesc;

  /// No description provided for @youthMobility.
  ///
  /// In it, this message translates to:
  /// **'Mobilità Giovanile'**
  String get youthMobility;

  /// No description provided for @youthMobilityDesc.
  ///
  /// In it, this message translates to:
  /// **'Opportunità di scambi internazionali, volontariato e stage all\'estero'**
  String get youthMobilityDesc;

  /// No description provided for @skillsDevelopment.
  ///
  /// In it, this message translates to:
  /// **'Sviluppo Competenze'**
  String get skillsDevelopment;

  /// No description provided for @skillsDevelopmentDesc.
  ///
  /// In it, this message translates to:
  /// **'Formazione e workshop per lo sviluppo di competenze personali e professionali'**
  String get skillsDevelopmentDesc;

  /// No description provided for @intergenerationalMentoring.
  ///
  /// In it, this message translates to:
  /// **'Mentoring Intergenerazionale'**
  String get intergenerationalMentoring;

  /// No description provided for @intergenerationalMentoringDesc.
  ///
  /// In it, this message translates to:
  /// **'Programmi di affiancamento tra donne di diverse generazioni'**
  String get intergenerationalMentoringDesc;

  /// No description provided for @womenNetworking.
  ///
  /// In it, this message translates to:
  /// **'Networking Femminile'**
  String get womenNetworking;

  /// No description provided for @womenNetworkingDesc.
  ///
  /// In it, this message translates to:
  /// **'Eventi e attività per creare una rete di supporto tra donne'**
  String get womenNetworkingDesc;

  /// No description provided for @leadershipTraining.
  ///
  /// In it, this message translates to:
  /// **'Formazione Leadership'**
  String get leadershipTraining;

  /// No description provided for @leadershipTrainingDesc.
  ///
  /// In it, this message translates to:
  /// **'Corsi e seminari per lo sviluppo della leadership femminile'**
  String get leadershipTrainingDesc;

  /// No description provided for @socialIntegrationSport.
  ///
  /// In it, this message translates to:
  /// **'Integrazione tramite Sport'**
  String get socialIntegrationSport;

  /// No description provided for @socialIntegrationSportDesc.
  ///
  /// In it, this message translates to:
  /// **'Attività sportive per favorire l\'inclusione sociale'**
  String get socialIntegrationSportDesc;

  /// No description provided for @inclusiveSportActivities.
  ///
  /// In it, this message translates to:
  /// **'Attività Sportive Inclusive'**
  String get inclusiveSportActivities;

  /// No description provided for @inclusiveSportActivitiesDesc.
  ///
  /// In it, this message translates to:
  /// **'Sport accessibili a tutti, indipendentemente dalle abilità'**
  String get inclusiveSportActivitiesDesc;

  /// No description provided for @communityEvents.
  ///
  /// In it, this message translates to:
  /// **'Eventi Comunitari'**
  String get communityEvents;

  /// No description provided for @communityEventsDesc.
  ///
  /// In it, this message translates to:
  /// **'Tornei e manifestazioni sportive per la comunità'**
  String get communityEventsDesc;

  /// No description provided for @migrantDesk.
  ///
  /// In it, this message translates to:
  /// **'Sportello Migranti'**
  String get migrantDesk;

  /// No description provided for @migrantDeskDesc.
  ///
  /// In it, this message translates to:
  /// **'Assistenza e orientamento per persone migranti'**
  String get migrantDeskDesc;

  /// No description provided for @documentSupport.
  ///
  /// In it, this message translates to:
  /// **'Supporto Documentale'**
  String get documentSupport;

  /// No description provided for @documentSupportDesc.
  ///
  /// In it, this message translates to:
  /// **'Aiuto nella compilazione e gestione di documenti amministrativi'**
  String get documentSupportDesc;

  /// No description provided for @legalGuidance.
  ///
  /// In it, this message translates to:
  /// **'Orientamento Legale'**
  String get legalGuidance;

  /// No description provided for @legalGuidanceDesc.
  ///
  /// In it, this message translates to:
  /// **'Consulenza e informazioni sui diritti e procedure legali'**
  String get legalGuidanceDesc;

  /// No description provided for @mafaldaService1.
  ///
  /// In it, this message translates to:
  /// **'Progettazione Europea'**
  String get mafaldaService1;

  /// No description provided for @mafaldaService2.
  ///
  /// In it, this message translates to:
  /// **'Mobilità Giovanile'**
  String get mafaldaService2;

  /// No description provided for @mafaldaService3.
  ///
  /// In it, this message translates to:
  /// **'Sviluppo Competenze'**
  String get mafaldaService3;

  /// No description provided for @mafaldaService4.
  ///
  /// In it, this message translates to:
  /// **'Networking Europeo'**
  String get mafaldaService4;

  /// No description provided for @womentorService1.
  ///
  /// In it, this message translates to:
  /// **'Mentoring Intergenerazionale'**
  String get womentorService1;

  /// No description provided for @womentorService2.
  ///
  /// In it, this message translates to:
  /// **'Networking Femminile'**
  String get womentorService2;

  /// No description provided for @womentorService3.
  ///
  /// In it, this message translates to:
  /// **'Formazione Leadership'**
  String get womentorService3;

  /// No description provided for @womentorService4.
  ///
  /// In it, this message translates to:
  /// **'Empowerment Professionale'**
  String get womentorService4;

  /// No description provided for @sportunityService1.
  ///
  /// In it, this message translates to:
  /// **'Integrazione tramite Sport'**
  String get sportunityService1;

  /// No description provided for @sportunityService2.
  ///
  /// In it, this message translates to:
  /// **'Attività Sportive Inclusive'**
  String get sportunityService2;

  /// No description provided for @sportunityService3.
  ///
  /// In it, this message translates to:
  /// **'Eventi Comunitari'**
  String get sportunityService3;

  /// No description provided for @sportunityService4.
  ///
  /// In it, this message translates to:
  /// **'Promozione Benessere'**
  String get sportunityService4;

  /// No description provided for @passaparolaService1.
  ///
  /// In it, this message translates to:
  /// **'Sportello Migranti'**
  String get passaparolaService1;

  /// No description provided for @passaparolaService2.
  ///
  /// In it, this message translates to:
  /// **'Supporto Documentale'**
  String get passaparolaService2;

  /// No description provided for @passaparolaService3.
  ///
  /// In it, this message translates to:
  /// **'Orientamento Legale'**
  String get passaparolaService3;

  /// No description provided for @passaparolaService4.
  ///
  /// In it, this message translates to:
  /// **'Integrazione Sociale'**
  String get passaparolaService4;

  /// No description provided for @chatbotTitle.
  ///
  /// In it, this message translates to:
  /// **'Assistenza & FAQ'**
  String get chatbotTitle;

  /// No description provided for @chatbotWelcome.
  ///
  /// In it, this message translates to:
  /// **'Ciao! 👋 Sono l\'assistente virtuale WECOOP. Come posso aiutarti oggi?'**
  String get chatbotWelcome;

  /// No description provided for @chatbotServicesResponse.
  ///
  /// In it, this message translates to:
  /// **'Offriamo diversi servizi:\n\n• Accoglienza e Orientamento\n• Mediazione Fiscale\n• Supporto Contabile\n• Servizi per Migranti\n\nQuale ti interessa?'**
  String get chatbotServicesResponse;

  /// No description provided for @chatbotProjectsResponse.
  ///
  /// In it, this message translates to:
  /// **'Abbiamo 4 macro-categorie di progetti:\n\n🔵 Giovani (MAFALDA)\n🟣 Donne (WOMENTOR)\n🟢 Sport (SPORTUNITY)\n🟠 Migranti (PASSAPAROLA)\n\nVuoi saperne di più?'**
  String get chatbotProjectsResponse;

  /// No description provided for @chatbotPermitResponse.
  ///
  /// In it, this message translates to:
  /// **'Ti serve il permesso di soggiorno? Possiamo aiutarti con:\n\n• Lavoro Subordinato\n• Lavoro Autonomo\n• Studio\n• Famiglia\n\nSeleziona il tipo che ti interessa.'**
  String get chatbotPermitResponse;

  /// No description provided for @chatbotCitizenshipResponse.
  ///
  /// In it, this message translates to:
  /// **'Per la cittadinanza italiana ti aiutiamo a:\n\n• Verificare i requisiti\n• Preparare la documentazione\n• Presentare la domanda\n\nVuoi iniziare la richiesta?'**
  String get chatbotCitizenshipResponse;

  /// No description provided for @chatbotAsylumResponse.
  ///
  /// In it, this message translates to:
  /// **'Ti aiutiamo con la richiesta di protezione internazionale. È un processo delicato e ti seguiremo passo passo.\n\nVuoi iniziare?'**
  String get chatbotAsylumResponse;

  /// No description provided for @chatbotTaxResponse.
  ///
  /// In it, this message translates to:
  /// **'Ti serve aiuto con il 730 o altri servizi fiscali?\n\nOffriamo:\n• Dichiarazione 730\n• Consulenza fiscale\n• Supporto contabile'**
  String get chatbotTaxResponse;

  /// No description provided for @chatbotAppointmentResponse.
  ///
  /// In it, this message translates to:
  /// **'Vuoi prenotare un appuntamento? Puoi farlo facilmente dalla nostra app!'**
  String get chatbotAppointmentResponse;

  /// No description provided for @chatbotGreeting.
  ///
  /// In it, this message translates to:
  /// **'Ciao! Come posso aiutarti oggi? 😊'**
  String get chatbotGreeting;

  /// No description provided for @chatbotThanksResponse.
  ///
  /// In it, this message translates to:
  /// **'Prego! Sono qui per aiutarti. C\'è altro che posso fare per te?'**
  String get chatbotThanksResponse;

  /// No description provided for @chatbotDefaultResponse.
  ///
  /// In it, this message translates to:
  /// **'Non sono sicuro di aver capito. Puoi dirmi:\n\n• \"Servizi\" per vedere i nostri servizi\n• \"Progetti\" per i nostri progetti\n• \"Permesso di soggiorno\"\n• \"Cittadinanza\"\n• \"730\" per servizi fiscali\n• \"Appuntamento\" per prenotare\n\nOppure seleziona una domanda qui sotto:'**
  String get chatbotDefaultResponse;

  /// No description provided for @chatbotGoToServices.
  ///
  /// In it, this message translates to:
  /// **'Vai ai servizi'**
  String get chatbotGoToServices;

  /// No description provided for @chatbotRequestCitizenship.
  ///
  /// In it, this message translates to:
  /// **'Richiedi Cittadinanza'**
  String get chatbotRequestCitizenship;

  /// No description provided for @chatbotStartRequest.
  ///
  /// In it, this message translates to:
  /// **'Inizia Richiesta'**
  String get chatbotStartRequest;

  /// No description provided for @chatbotFiscalServices.
  ///
  /// In it, this message translates to:
  /// **'Servizi Fiscali'**
  String get chatbotFiscalServices;

  /// No description provided for @chatbotBookNow.
  ///
  /// In it, this message translates to:
  /// **'Prenota Ora'**
  String get chatbotBookNow;

  /// No description provided for @chatbotWelcomeBtn.
  ///
  /// In it, this message translates to:
  /// **'Accoglienza'**
  String get chatbotWelcomeBtn;

  /// No description provided for @chatbotFiscalBtn.
  ///
  /// In it, this message translates to:
  /// **'Servizi Fiscali'**
  String get chatbotFiscalBtn;

  /// No description provided for @chatbotMigrantsBtn.
  ///
  /// In it, this message translates to:
  /// **'Servizi Migranti'**
  String get chatbotMigrantsBtn;

  /// No description provided for @chatbotWelcomeService.
  ///
  /// In it, this message translates to:
  /// **'Accoglienza e Orientamento'**
  String get chatbotWelcomeService;

  /// No description provided for @chatbotFiscalService.
  ///
  /// In it, this message translates to:
  /// **'Mediazione Fiscale'**
  String get chatbotFiscalService;

  /// No description provided for @chatbotMigrantsService.
  ///
  /// In it, this message translates to:
  /// **'Servizi per Migranti'**
  String get chatbotMigrantsService;

  /// No description provided for @chatbotWelcomeDetail.
  ///
  /// In it, this message translates to:
  /// **'Il servizio di Accoglienza ti aiuta con orientamento e supporto iniziale. Vuoi maggiori informazioni?'**
  String get chatbotWelcomeDetail;

  /// No description provided for @chatbotGoToService.
  ///
  /// In it, this message translates to:
  /// **'Vai al Servizio'**
  String get chatbotGoToService;

  /// No description provided for @chatbotYouthBtn.
  ///
  /// In it, this message translates to:
  /// **'Giovani'**
  String get chatbotYouthBtn;

  /// No description provided for @chatbotWomenBtn.
  ///
  /// In it, this message translates to:
  /// **'Donne'**
  String get chatbotWomenBtn;

  /// No description provided for @chatbotSportBtn.
  ///
  /// In it, this message translates to:
  /// **'Sport'**
  String get chatbotSportBtn;

  /// No description provided for @chatbotMigrantsProjectBtn.
  ///
  /// In it, this message translates to:
  /// **'Migranti'**
  String get chatbotMigrantsProjectBtn;

  /// No description provided for @chatbotYouthProjects.
  ///
  /// In it, this message translates to:
  /// **'Progetti Giovani'**
  String get chatbotYouthProjects;

  /// No description provided for @chatbotWomenProjects.
  ///
  /// In it, this message translates to:
  /// **'Progetti Donne'**
  String get chatbotWomenProjects;

  /// No description provided for @chatbotSportProjects.
  ///
  /// In it, this message translates to:
  /// **'Progetti Sport'**
  String get chatbotSportProjects;

  /// No description provided for @chatbotMigrantsProjects.
  ///
  /// In it, this message translates to:
  /// **'Progetti Migranti'**
  String get chatbotMigrantsProjects;

  /// No description provided for @chatbotServicesQuick.
  ///
  /// In it, this message translates to:
  /// **'Servizi'**
  String get chatbotServicesQuick;

  /// No description provided for @chatbotProjectsQuick.
  ///
  /// In it, this message translates to:
  /// **'Progetti'**
  String get chatbotProjectsQuick;

  /// No description provided for @chatbotPermitQuick.
  ///
  /// In it, this message translates to:
  /// **'Permesso Soggiorno'**
  String get chatbotPermitQuick;

  /// No description provided for @chatbotCitizenshipQuick.
  ///
  /// In it, this message translates to:
  /// **'Cittadinanza'**
  String get chatbotCitizenshipQuick;

  /// No description provided for @chatbotAppointmentQuick.
  ///
  /// In it, this message translates to:
  /// **'Appuntamento'**
  String get chatbotAppointmentQuick;

  /// No description provided for @chatbotFAQTitle.
  ///
  /// In it, this message translates to:
  /// **'❓ Domande Frequenti (FAQ)'**
  String get chatbotFAQTitle;

  /// No description provided for @chatbotFAQ1Question.
  ///
  /// In it, this message translates to:
  /// **'Come posso richiedere il permesso di soggiorno?'**
  String get chatbotFAQ1Question;

  /// No description provided for @chatbotFAQ1Answer.
  ///
  /// In it, this message translates to:
  /// **'Vai su Servizi > Servizi per Migranti > Permesso di Soggiorno e seleziona la categoria appropriata.'**
  String get chatbotFAQ1Answer;

  /// No description provided for @chatbotFAQ2Question.
  ///
  /// In it, this message translates to:
  /// **'Quali documenti servono per il 730?'**
  String get chatbotFAQ2Question;

  /// No description provided for @chatbotFAQ2Answer.
  ///
  /// In it, this message translates to:
  /// **'Ti serviranno: CU, documenti di spesa detraibili, codice fiscale. Possiamo aiutarti nella compilazione!'**
  String get chatbotFAQ2Answer;

  /// No description provided for @chatbotFAQ3Question.
  ///
  /// In it, this message translates to:
  /// **'Che progetti avete per i giovani?'**
  String get chatbotFAQ3Question;

  /// No description provided for @chatbotFAQ3Answer.
  ///
  /// In it, this message translates to:
  /// **'Il progetto MAFALDA offre opportunità di mobilità europea, formazione e sviluppo competenze.'**
  String get chatbotFAQ3Answer;

  /// No description provided for @chatbotFAQ4Question.
  ///
  /// In it, this message translates to:
  /// **'Come posso diventare socio?'**
  String get chatbotFAQ4Question;

  /// No description provided for @chatbotFAQ4Answer.
  ///
  /// In it, this message translates to:
  /// **'Dal tuo profilo clicca su \"Diventa Socio WECOOP\" e compila il modulo di adesione.'**
  String get chatbotFAQ4Answer;

  /// No description provided for @chatbotFAQ5Question.
  ///
  /// In it, this message translates to:
  /// **'Come prenoto un appuntamento?'**
  String get chatbotFAQ5Question;

  /// No description provided for @chatbotFAQ5Answer.
  ///
  /// In it, this message translates to:
  /// **'Puoi prenotare direttamente dall\'app cliccando su \"Prenota Appuntamento\".'**
  String get chatbotFAQ5Answer;

  /// No description provided for @chatbotInputHint.
  ///
  /// In it, this message translates to:
  /// **'Scrivi un messaggio...'**
  String get chatbotInputHint;

  /// No description provided for @alreadyRegisteredLogin.
  ///
  /// In it, this message translates to:
  /// **'Se sei già registrato effettua il login'**
  String get alreadyRegisteredLogin;

  /// No description provided for @continueWithoutLogin.
  ///
  /// In it, this message translates to:
  /// **'Continua senza loggarti'**
  String get continueWithoutLogin;

  /// No description provided for @alreadyRegistered.
  ///
  /// In it, this message translates to:
  /// **'Sei già registrato?'**
  String get alreadyRegistered;

  /// No description provided for @loginToAccess.
  ///
  /// In it, this message translates to:
  /// **'Accedi per utilizzare tutti i servizi'**
  String get loginToAccess;
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

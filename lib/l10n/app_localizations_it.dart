// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'WECOOP';

  @override
  String get hello => 'Ciao';

  @override
  String get welcome =>
      'Benvenuta su WECOOP! Esplora eventi, servizi e progetti vicino a te.';

  @override
  String get user => 'Utente';

  @override
  String get profile => 'Profilo';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Richieste';

  @override
  String get projects => 'Progetti';

  @override
  String get services => 'Servizi';

  @override
  String get notifications => 'Notifiche';

  @override
  String get login => 'Accedi';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Logout effettuato';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get rememberPassword => 'Ricorda password';

  @override
  String get loginButton => 'ACCEDI';

  @override
  String get loginError => 'Login fallito';

  @override
  String get networkError => 'Errore di rete';

  @override
  String get emailNotAvailable => 'email non disponibile';

  @override
  String get memberCard => 'Tessera Socio WECOOP';

  @override
  String get cardNumber => 'N° Tessera';

  @override
  String get cardNotAvailable => 'Tessera non disponibile';

  @override
  String get openDigitalCard => 'Apri tessera digitale';

  @override
  String get preferences => 'Preferenze';

  @override
  String get language => 'Lingua';

  @override
  String get areaOfInterest => 'Area di interesse';

  @override
  String get participationHistory => 'Storico partecipazioni';

  @override
  String get italian => 'Italiano';

  @override
  String get english => 'Inglese';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get arabic => 'Arabo';

  @override
  String get culture => 'Cultura';

  @override
  String get sport => 'Sport';

  @override
  String get training => 'Formazione';

  @override
  String get volunteering => 'Volontariato';

  @override
  String get socialServices => 'Servizi sociali';

  @override
  String get servicesTitle => '🛠️ Servizi';

  @override
  String get welcomeService => 'Accoglienza';

  @override
  String get taxMediationService => 'Mediazione fiscale';

  @override
  String get accountingService => 'Supporto contabile';

  @override
  String get seeAll => 'Vedi tutti';

  @override
  String get upcomingEvents => '📅 Prossimi eventi';

  @override
  String get activeProjects => '🤝 Progetti attivi';

  @override
  String get latestNews => '📰 Ultime notizie';

  @override
  String get quickAccess => '⚡ Accesso rapido';

  @override
  String get eventInterculturalDinner => 'Cena Interculturale';

  @override
  String get eventSewingLab => 'Laboratorio di cucito';

  @override
  String get eventItalianCourse => 'Corso di italiano';

  @override
  String get projectMafalda => 'MAFALDA';

  @override
  String get projectMafaldaDesc => 'Giovani e inclusione';

  @override
  String get projectWomentor => 'WOMENTOR';

  @override
  String get projectWomentorDesc => 'Mentoring tra donne';

  @override
  String get projectSportunity => 'SPORTUNITY';

  @override
  String get projectSportunityDesc => 'Sport e comunità';

  @override
  String get loading => 'Caricamento...';

  @override
  String get noNews => 'Nessuna notizia disponibile';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get myRequests => 'Le Mie Richieste';

  @override
  String get allRequests => 'Tutte';

  @override
  String get pendingPayment => 'In attesa pagamento';

  @override
  String get processing => 'In lavorazione';

  @override
  String get completed => 'Completate';

  @override
  String get cancelled => 'Annullate';

  @override
  String get requestDetails => 'Dettaglio Richiesta';

  @override
  String get service => 'Servizio';

  @override
  String get description => 'Descrizione';

  @override
  String get requestDate => 'Data Richiesta';

  @override
  String get status => 'Stato';

  @override
  String get paymentInfo => 'Informazioni Pagamento';

  @override
  String get paymentStatus => 'Stato Pagamento';

  @override
  String get paid => 'Pagato';

  @override
  String get notPaid => 'Non pagato';

  @override
  String get paymentMethod => 'Metodo';

  @override
  String get paymentDate => 'Data Pagamento';

  @override
  String get transactionId => 'ID Transazione';

  @override
  String get amount => 'Importo';

  @override
  String get payNow => 'Paga ora';

  @override
  String get cannotOpenPaymentLink => 'Impossibile aprire il link di pagamento';

  @override
  String get noRequestsForDay => 'Nessuna richiesta per questo giorno';

  @override
  String get noRequests => 'Nessuna richiesta trovata';

  @override
  String get close => 'Chiudi';

  @override
  String get loginToAccessServices =>
      'Effettua il login per accedere a tutti i servizi riservati ai soci.';

  @override
  String get membershipPendingApproval =>
      'La tua richiesta di adesione come socio è in fase di approvazione.';

  @override
  String get confirmationWithin24to48Hours =>
      'Riceverai una conferma via email entro 24-48 ore.';

  @override
  String get onceApprovedAccessAllServices =>
      'Una volta approvata, potrai accedere a tutti i servizi.';

  @override
  String toAccessServicesBecomeMember(Object serviceName) {
    return 'Per accedere ai servizi di $serviceName devi essere socio di WECOOP.';
  }

  @override
  String get becomeMemberToAccess => 'Diventa socio per accedere a:';

  @override
  String get whyBecomeMember => 'Perché diventare socio?';

  @override
  String get operationCompleted => 'Operazione completata';

  @override
  String get fiscalCodeMustBe16Chars =>
      'Il codice fiscale deve essere di 16 caratteri';

  @override
  String get birthPlace => 'Luogo di Nascita';

  @override
  String get invalidPostalCode => 'CAP non valido';

  @override
  String get invalidEmail => 'Email non valida';

  @override
  String get fillFollowingFields => 'Compila i seguenti campi';

  @override
  String get sendingError => 'Errore durante l\'invio';

  @override
  String get politicalAsylum => 'Asilo Politico';

  @override
  String get internationalProtectionRequest =>
      'La richiesta di protezione internazionale è un processo delicato. Ti aiuteremo a preparare la documentazione.';

  @override
  String get internationalProtection => 'Protezione Internazionale';

  @override
  String get fullName => 'Nome completo';

  @override
  String get dateOfBirth => 'Data di nascita';

  @override
  String get countryOfOrigin => 'Paese di origine';

  @override
  String get dateOfArrivalInItaly => 'Data di arrivo in Italia';

  @override
  String get reasonForRequest => 'Motivo della richiesta';

  @override
  String get politicalPersecution => 'Persecuzione politica';

  @override
  String get religiousPersecution => 'Persecuzione religiosa';

  @override
  String get persecutionSexualOrientation =>
      'Persecuzione per orientamento sessuale';

  @override
  String get war => 'Guerra';

  @override
  String get other => 'Altro';

  @override
  String get situationDescription => 'Descrizione situazione';

  @override
  String get hasFamilyInItaly => 'Hai familiari in Italia?';

  @override
  String get additionalNotes => 'Note aggiuntive';

  @override
  String get startRequest => 'Inizia la richiesta';

  @override
  String get touristVisaRequest => 'Richiesta Visa per Turismo';

  @override
  String get taxMediation => 'Mediazione Fiscale';

  @override
  String get accountingSupport => 'Supporto Contabile';

  @override
  String get residencePermit => 'Permesso di Soggiorno';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get selectFiscalService => 'Seleziona il servizio fiscale';

  @override
  String get tax730Declaration => '730 - Dichiarazione dei Redditi';

  @override
  String get tax730Description =>
      'Compilazione modello 730 per dipendenti e pensionati';

  @override
  String get individualPerson => 'Persona Fisica';

  @override
  String get individualPersonDescription =>
      'Dichiarazione redditi per persone fisiche';

  @override
  String get taxpayerType => 'Tipologia contribuente';

  @override
  String get employee => 'Lavoratore dipendente';

  @override
  String get pensioner => 'Pensionato';

  @override
  String get fiscalYear => 'Anno fiscale';

  @override
  String get hasDeductibleExpenses => 'Hai spese detraibili/deducibili?';

  @override
  String get notesAndAdditionalInfo => 'Note e informazioni aggiuntive';

  @override
  String get incomeType => 'Tipologia di reddito';

  @override
  String get employedWork => 'Lavoro dipendente';

  @override
  String get selfEmployed => 'Lavoro autonomo';

  @override
  String get pension => 'Pensione';

  @override
  String get capitalIncome => 'Redditi da capitale';

  @override
  String get otherIncome => 'Redditi diversi';

  @override
  String get multipleTypes => 'Più tipologie';

  @override
  String get hasProperties => 'Hai immobili?';

  @override
  String get detailsAndNotes => 'Dettagli e note';
}

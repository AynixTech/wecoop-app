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

  @override
  String get youthCategory => 'Giovani';

  @override
  String get womenCategory => 'Donne';

  @override
  String get sportsCategory => 'Sport';

  @override
  String get migrantsCategory => 'Migranti';

  @override
  String get projectDescription => 'Descrizione del progetto';

  @override
  String get servicesOffered => 'Servizi offerti';

  @override
  String get mafaldaDescription =>
      'Progetto europeo dedicato ai giovani per lo sviluppo di competenze e opportunità di mobilità internazionale.';

  @override
  String get womentorDescription =>
      'Programma di mentoring e networking intergenerazionale tra donne per la crescita personale e professionale.';

  @override
  String get sportunityDescription =>
      'Integrazione sociale e inclusione attraverso lo sport e attività ricreative per tutta la comunità.';

  @override
  String get passaparolaDescription =>
      'Sportello dedicato ai migranti per supporto documentale, orientamento e integrazione sociale.';

  @override
  String get europeanProjectDesign => 'Progettazione Europea';

  @override
  String get europeanProjectDesignDesc =>
      'Supporto nella progettazione e gestione di progetti finanziati dall\'Unione Europea';

  @override
  String get youthMobility => 'Mobilità Giovanile';

  @override
  String get youthMobilityDesc =>
      'Opportunità di scambi internazionali, volontariato e stage all\'estero';

  @override
  String get skillsDevelopment => 'Sviluppo Competenze';

  @override
  String get skillsDevelopmentDesc =>
      'Formazione e workshop per lo sviluppo di competenze personali e professionali';

  @override
  String get intergenerationalMentoring => 'Mentoring Intergenerazionale';

  @override
  String get intergenerationalMentoringDesc =>
      'Programmi di affiancamento tra donne di diverse generazioni';

  @override
  String get womenNetworking => 'Networking Femminile';

  @override
  String get womenNetworkingDesc =>
      'Eventi e attività per creare una rete di supporto tra donne';

  @override
  String get leadershipTraining => 'Formazione Leadership';

  @override
  String get leadershipTrainingDesc =>
      'Corsi e seminari per lo sviluppo della leadership femminile';

  @override
  String get socialIntegrationSport => 'Integrazione tramite Sport';

  @override
  String get socialIntegrationSportDesc =>
      'Attività sportive per favorire l\'inclusione sociale';

  @override
  String get inclusiveSportActivities => 'Attività Sportive Inclusive';

  @override
  String get inclusiveSportActivitiesDesc =>
      'Sport accessibili a tutti, indipendentemente dalle abilità';

  @override
  String get communityEvents => 'Eventi Comunitari';

  @override
  String get communityEventsDesc =>
      'Tornei e manifestazioni sportive per la comunità';

  @override
  String get migrantDesk => 'Sportello Migranti';

  @override
  String get migrantDeskDesc =>
      'Assistenza e orientamento per persone migranti';

  @override
  String get documentSupport => 'Supporto Documentale';

  @override
  String get documentSupportDesc =>
      'Aiuto nella compilazione e gestione di documenti amministrativi';

  @override
  String get legalGuidance => 'Orientamento Legale';

  @override
  String get legalGuidanceDesc =>
      'Consulenza e informazioni sui diritti e procedure legali';

  @override
  String get mafaldaService1 => 'Progettazione Europea';

  @override
  String get mafaldaService2 => 'Mobilità Giovanile';

  @override
  String get mafaldaService3 => 'Sviluppo Competenze';

  @override
  String get mafaldaService4 => 'Networking Europeo';

  @override
  String get womentorService1 => 'Mentoring Intergenerazionale';

  @override
  String get womentorService2 => 'Networking Femminile';

  @override
  String get womentorService3 => 'Formazione Leadership';

  @override
  String get womentorService4 => 'Empowerment Professionale';

  @override
  String get sportunityService1 => 'Integrazione tramite Sport';

  @override
  String get sportunityService2 => 'Attività Sportive Inclusive';

  @override
  String get sportunityService3 => 'Eventi Comunitari';

  @override
  String get sportunityService4 => 'Promozione Benessere';

  @override
  String get passaparolaService1 => 'Sportello Migranti';

  @override
  String get passaparolaService2 => 'Supporto Documentale';

  @override
  String get passaparolaService3 => 'Orientamento Legale';

  @override
  String get passaparolaService4 => 'Integrazione Sociale';

  @override
  String get chatbotTitle => 'Assistenza & FAQ';

  @override
  String get chatbotWelcome =>
      'Ciao! 👋 Sono l\'assistente virtuale WECOOP. Come posso aiutarti oggi?';

  @override
  String get chatbotServicesResponse =>
      'Offriamo diversi servizi:\n\n• Accoglienza e Orientamento\n• Mediazione Fiscale\n• Supporto Contabile\n• Servizi per Migranti\n\nQuale ti interessa?';

  @override
  String get chatbotProjectsResponse =>
      'Abbiamo 4 macro-categorie di progetti:\n\n🔵 Giovani (MAFALDA)\n🟣 Donne (WOMENTOR)\n🟢 Sport (SPORTUNITY)\n🟠 Migranti (PASSAPAROLA)\n\nVuoi saperne di più?';

  @override
  String get chatbotPermitResponse =>
      'Ti serve il permesso di soggiorno? Possiamo aiutarti con:\n\n• Lavoro Subordinato\n• Lavoro Autonomo\n• Studio\n• Famiglia\n\nSeleziona il tipo che ti interessa.';

  @override
  String get chatbotCitizenshipResponse =>
      'Per la cittadinanza italiana ti aiutiamo a:\n\n• Verificare i requisiti\n• Preparare la documentazione\n• Presentare la domanda\n\nVuoi iniziare la richiesta?';

  @override
  String get chatbotAsylumResponse =>
      'Ti aiutiamo con la richiesta di protezione internazionale. È un processo delicato e ti seguiremo passo passo.\n\nVuoi iniziare?';

  @override
  String get chatbotTaxResponse =>
      'Ti serve aiuto con il 730 o altri servizi fiscali?\n\nOffriamo:\n• Dichiarazione 730\n• Consulenza fiscale\n• Supporto contabile';

  @override
  String get chatbotAppointmentResponse =>
      'Vuoi prenotare un appuntamento? Puoi farlo facilmente dalla nostra app!';

  @override
  String get chatbotGreeting => 'Ciao! Come posso aiutarti oggi? 😊';

  @override
  String get chatbotThanksResponse =>
      'Prego! Sono qui per aiutarti. C\'è altro che posso fare per te?';

  @override
  String get chatbotDefaultResponse =>
      'Non sono sicuro di aver capito. Puoi dirmi:\n\n• \"Servizi\" per vedere i nostri servizi\n• \"Progetti\" per i nostri progetti\n• \"Permesso di soggiorno\"\n• \"Cittadinanza\"\n• \"730\" per servizi fiscali\n• \"Appuntamento\" per prenotare\n\nOppure seleziona una domanda qui sotto:';

  @override
  String get chatbotGoToServices => 'Vai ai servizi';

  @override
  String get chatbotRequestCitizenship => 'Richiedi Cittadinanza';

  @override
  String get chatbotStartRequest => 'Inizia Richiesta';

  @override
  String get chatbotFiscalServices => 'Servizi Fiscali';

  @override
  String get chatbotBookNow => 'Prenota Ora';

  @override
  String get chatbotWelcomeBtn => 'Accoglienza';

  @override
  String get chatbotFiscalBtn => 'Servizi Fiscali';

  @override
  String get chatbotMigrantsBtn => 'Servizi Migranti';

  @override
  String get chatbotWelcomeService => 'Accoglienza e Orientamento';

  @override
  String get chatbotFiscalService => 'Mediazione Fiscale';

  @override
  String get chatbotMigrantsService => 'Servizi per Migranti';

  @override
  String get chatbotWelcomeDetail =>
      'Il servizio di Accoglienza ti aiuta con orientamento e supporto iniziale. Vuoi maggiori informazioni?';

  @override
  String get chatbotGoToService => 'Vai al Servizio';

  @override
  String get chatbotYouthBtn => 'Giovani';

  @override
  String get chatbotWomenBtn => 'Donne';

  @override
  String get chatbotSportBtn => 'Sport';

  @override
  String get chatbotMigrantsProjectBtn => 'Migranti';

  @override
  String get chatbotYouthProjects => 'Progetti Giovani';

  @override
  String get chatbotWomenProjects => 'Progetti Donne';

  @override
  String get chatbotSportProjects => 'Progetti Sport';

  @override
  String get chatbotMigrantsProjects => 'Progetti Migranti';

  @override
  String get chatbotServicesQuick => 'Servizi';

  @override
  String get chatbotProjectsQuick => 'Progetti';

  @override
  String get chatbotPermitQuick => 'Permesso Soggiorno';

  @override
  String get chatbotCitizenshipQuick => 'Cittadinanza';

  @override
  String get chatbotAppointmentQuick => 'Appuntamento';

  @override
  String get chatbotFAQTitle => '❓ Domande Frequenti (FAQ)';

  @override
  String get chatbotFAQ1Question =>
      'Come posso richiedere il permesso di soggiorno?';

  @override
  String get chatbotFAQ1Answer =>
      'Vai su Servizi > Servizi per Migranti > Permesso di Soggiorno e seleziona la categoria appropriata.';

  @override
  String get chatbotFAQ2Question => 'Quali documenti servono per il 730?';

  @override
  String get chatbotFAQ2Answer =>
      'Ti serviranno: CU, documenti di spesa detraibili, codice fiscale. Possiamo aiutarti nella compilazione!';

  @override
  String get chatbotFAQ3Question => 'Che progetti avete per i giovani?';

  @override
  String get chatbotFAQ3Answer =>
      'Il progetto MAFALDA offre opportunità di mobilità europea, formazione e sviluppo competenze.';

  @override
  String get chatbotFAQ4Question => 'Come posso diventare socio?';

  @override
  String get chatbotFAQ4Answer =>
      'Dal tuo profilo clicca su \"Diventa Socio WECOOP\" e compila il modulo di adesione.';

  @override
  String get chatbotFAQ5Question => 'Come prenoto un appuntamento?';

  @override
  String get chatbotFAQ5Answer =>
      'Puoi prenotare direttamente dall\'app cliccando su \"Prenota Appuntamento\".';

  @override
  String get chatbotInputHint => 'Scrivi un messaggio...';

  @override
  String get alreadyRegisteredLogin =>
      'Se sei già registrato effettua il login';

  @override
  String get continueWithoutLogin => 'Continua senza loggarti';
}

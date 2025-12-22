import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'it': {
      'appTitle': 'WECOOP',
      'hello': 'Ciao',
      'welcome': 'Benvenuta su WECOOP! Esplora eventi, servizi e progetti vicino a te.',
      'user': 'Utente',
      'profile': 'Profilo',
      'home': 'Home',
      'events': 'Eventi',
      'calendar': 'Richieste',
      'projects': 'Progetti',
      'services': 'Servizi',
      'notifications': 'Notifiche',
      'login': 'Accedi',
      'logout': 'Logout',
      'logoutConfirm': 'Logout effettuato',
      'email': 'Email',
      'password': 'Password',
      'memberCard': 'Tessera Socio WECOOP',
      'cardNumber': 'N° Tessera',
      'openDigitalCard': 'Apri tessera digitale',
      'preferences': 'Preferenze',
      'language': 'Lingua',
      'areaOfInterest': 'Area di interesse',
      'participationHistory': 'Storico partecipazioni',
      'culture': 'Cultura',
      'sport': 'Sport',
      'training': 'Formazione',
      'volunteering': 'Volontariato',
      'socialServices': 'Servizi sociali',
      'rememberPassword': 'Ricorda password',
      'networkError': 'Errore di rete',
      'upcomingEvents': 'Prossimi eventi',
      'activeProjects': 'Progetti attivi',
      'quickAccess': 'Accesso rapido',
      'communityMap': 'Mappa Comunità',
      'resourcesGuides': 'Risorse e Guide',
      'localGroups': 'Gruppi Locali',
      'forumDiscussions': 'Forum & Discussioni',
      'support': 'Supporto',
      'ourServices': 'I nostri servizi',
      'welcomeOrientation': 'Accoglienza e Orientamento',
      'taxMediation': 'Mediazione Fiscale',
      'accountingSupport': 'Supporto Contabile',
      'latestArticles': 'Ultimi articoli',
      'errorLoading': 'Errore',
      'noArticlesAvailable': 'Nessun articolo disponibile.',
      'myRequests': 'Le Mie Richieste',
      'payNow': 'Paga Ora',
      'cannotOpenPaymentLink': 'Impossibile aprire il link di pagamento',
      'errorLoadingData': 'Errore nel caricamento',
      'sportello': 'Sportello',
      'digitalDesk': 'Sportello Digitale',
      'serviceRequest': 'Richiesta di servizio',
      'selectService': 'Seleziona un servizio',
      'bookAppointment': 'Prenota Appuntamento',
      'chatbotSupport': 'Chatbot / Supporto',
      'chatbotUnavailable': 'Chatbot non disponibile al momento',
      'bookDigitalAppointment': 'Prenota Appuntamento Digitale',
      'proposeEvent': 'Proponi corso o evento',
      'proposeEventTitle': 'Proponi un corso o evento',
      'featureInDevelopment': 'Funzionalità in sviluppo.',
      'close': 'Chiudi',
      'becomeMember': 'Diventa Socio WECOOP',
      'requestSent': 'Richiesta inviata!',
      'requestReceived': 'Abbiamo ricevuto la tua richiesta di adesione. Ti contatteremo presto per completare il processo.',
      'ok': 'OK',
      'error': 'Errore',
      'emailAlreadyRegistered': 'Email già registrata',
      'emailExistsMessage': 'Questa email risulta già registrata nel nostro sistema. Vuoi accedere con le tue credenziali?',
      'cancel': 'Annulla',
      'goToLogin': 'Vai al Login',
      'personalInfo': 'Dati Personali',
      'name': 'Nome',
      'surname': 'Cognome',
      'birthDate': 'Data di nascita',
      'dateFormat': 'gg/mm/aaaa',
      'fiscalCode': 'Codice Fiscale',
      'contactInfo': 'Contatti',
      'phone': 'Telefono',
      'address': 'Indirizzo',
      'residenceAddress': 'Indirizzo di residenza',
      'city': 'Città',
      'province': 'Provincia',
      'postalCode': 'CAP',
      'additionalInfo': 'Informazioni aggiuntive',
      'additionalInfoPlaceholder': 'Eventuali informazioni aggiuntive',
      'privacyConsent': 'Accetto il trattamento dei dati personali',
      'sendRequest': 'Invia Richiesta',
      'myEvents': 'I miei eventi',
      'notEnrolledInEvents': 'Non sei iscritto a nessun evento',
      'reload': 'Ricarica',
      'allEvents': 'Tutti gli eventi',
      'cultural': 'Culturali',
      'sports': 'Sportivi',
      'social': 'Sociali',
      'retry': 'Riprova',
      'noEventsAvailable': 'Nessun evento disponibile',
      'enrolled': 'Iscritto',
      'eventConcluded': 'EVENTO CONCLUSO',
      'loading': 'Caricamento...',
      'confirmCancellation': 'Conferma cancellazione',
      'confirmCancellationMessage': 'Sei sicuro di voler cancellare la tua iscrizione?',
      'cancelEnrollment': 'Cancella iscrizione',
      'date': 'Data',
      'end': 'Fine',
      'place': 'Luogo',
      'price': 'Prezzo',
      'organizer': 'Organizzatore',
      'descriptionLabel': 'Descrizione',
      'program': 'Programma',
      'gallery': 'Galleria',
      'enrollNow': 'Iscriviti',
      'soldOut': 'POSTI ESAURITI',
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mer',
      'thursday': 'Gio',
      'friday': 'Ven',
      'saturday': 'Sab',
      'sunday': 'Dom',
      'january': 'Gen',
      'february': 'Feb',
      'march': 'Mar',
      'april': 'Apr',
      'may': 'Mag',
      'june': 'Giu',
      'july': 'Lug',
      'august': 'Ago',
      'september': 'Set',
      'october': 'Ott',
      'november': 'Nov',
      'december': 'Dic',
      'online': 'Online',
      'locationToBeDefined': 'Luogo da definire',
      'participants': 'partecipanti',
      'spotsRemaining': 'posti rimasti',
      'sending': 'Invio in corso...',
      'fillAllFields': 'Compila tutti i campi',
      'bookingConfirmed': 'Prenotazione confermata!',
      'connectionError': 'Errore di connessione',
      'selectDate': 'Seleziona una data',
      'availableSlots': 'Orari disponibili',
      'book': 'Prenora',
      'selectType': 'Seleziona la tipologia',
      'residencePermit': 'Permesso di Soggiorno',
      'checkRequirements': 'Verifica requisiti',
      'familySection': 'Sezione Famiglia',
      'incomeSection': 'Sezione Reddito',
      'expensesSection': 'Sezione Spese',
      'compilation730': 'Compilazione 730',
      'data730SentSuccess': 'Dati 730 inviati con successo',
      'allFieldsRequired': 'Errore: tutti i campi sono obbligatori',
      'fiscalData': 'Dati fiscali',
      'incomeData': 'Dati reddituali',
      'deductions': 'Detrazioni',
      'send730': 'Invia 730',
      'citizenshipService': 'Cittadinanza',
      'citizenshipIntro': 'Servizio di supporto per ottenere la cittadinanza italiana',
      'citizenshipDescription': 'Compila il questionario per verificare se hai i requisiti necessari.',
      'requirementsNotMet': 'Requisiti non soddisfatti',
      'requirementsMessage': 'Al momento non soddisfi tutti i requisiti necessari per richiedere la cittadinanza. Ti consigliamo di contattarci per una consulenza personalizzata.',
      'understand': 'Ho capito',
      'contactUs': 'Contattaci',
      'yes': 'Sì',
      'no': 'No',
      'needLogin': 'Servizio riservato ai soci',
      'needLoginMessage': 'Per accedere a questo servizio devi essere registrato come socio WECOOP.',
      'goBack': 'Torna indietro',
      'notMemberYet': 'Non sei ancora socio?',
      'notMemberMessage': 'Per accedere a questo servizio devi essere socio di WECOOP.',
      'backToHome': 'Torna alla home',
      'serviceNotAvailable': 'Servizio non disponibile',
      'serviceNotAvailableMessage': 'Questo servizio non è ancora attivo. Torna più tardi o contatta il nostro supporto per maggiori informazioni.',
      'all': 'Tutti',
      'pending': 'In attesa',
      'approved': 'Approvato',
      'rejected': 'Rifiutato',
      'selectServiceYouNeed': 'Seleziona il servizio di cui hai bisogno',
      'guideStepByStep': 'Ti guideremo passo dopo passo per completare la tua richiesta',
      'residencePermitDesc': 'Richiesta, rinnovo e informazioni',
      'citizenship': 'Cittadinanza',
      'citizenshipDesc': 'Richiesta cittadinanza italiana',
      'politicalAsylum': 'Asilo Politico',
      'politicalAsylumDesc': 'Protezione internazionale',
      'touristVisa': 'Visa per Turismo',
      'touristVisaDesc': 'Richiesta visto turistico',
      'loginToAccessServices': 'Effettua il login per accedere a tutti i servizi riservati ai soci.',
      'membershipPendingApproval': 'La tua richiesta di adesione come socio è in fase di approvazione.',
      'confirmationWithin24to48Hours': 'Riceverai una conferma via email entro 24-48 ore.',
      'onceApprovedAccessAllServices': 'Una volta approvata, potrai accedere a tutti i servizi.',
      'toAccessServicesBecomeMember': 'Per accedere ai servizi di {serviceName} devi essere socio di WECOOP.',
      'becomeMemberToAccess': 'Diventa socio per accedere a:',
      'whyBecomeMember': 'Perché diventare socio?',
      'fiscalCodeMustBe16Chars': 'Il codice fiscale deve essere di 16 caratteri',
      'birthPlace': 'Luogo di Nascita',
      'invalidPostalCode': 'CAP non valido',
      'invalidEmail': 'Email non valida',
      'fillFollowingFields': 'Compila i seguenti campi',
      'sendingError': 'Errore durante l\'invio',
      'internationalProtectionRequest': 'La richiesta di protezione internazionale è un processo delicato. Ti aiuteremo a preparare la documentazione.',
      'internationalProtection': 'Protezione Internazionale',
      'fullName': 'Nome completo',
      'dateOfBirth': 'Data di nascita',
      'countryOfOrigin': 'Paese di origine',
      'dateOfArrivalInItaly': 'Data di arrivo in Italia',
      'reasonForRequest': 'Motivo della richiesta',
      'politicalPersecution': 'Persecuzione politica',
      'religiousPersecution': 'Persecuzione religiosa',
      'persecutionSexualOrientation': 'Persecuzione per orientamento sessuale',
      'war': 'Guerra',
      'other': 'Altro',
      'situationDescription': 'Descrizione situazione',
      'hasFamilyInItaly': 'Hai familiari in Italia?',
      'additionalNotes': 'Note aggiuntive',
      'startRequest': 'Inizia la richiesta',
      'touristVisaRequest': 'Richiesta Visto Turistico',
      'touristVisaCategory': 'Visto turistico',
      'nationality': 'Nazionalità',
      'passportNumber': 'Numero passaporto',
      'expectedArrivalDate': 'Data arrivo prevista',
      'expectedDepartureDate': 'Data partenza prevista',
      'travelReason': 'Motivo del viaggio',
      'tourism': 'Turismo',
      'familyVisit': 'Visita famiglia',
      'business': 'Affari',
      'accommodationAddressItaly': 'Indirizzo di soggiorno in Italia',
      'fillRequest': 'Compila richiesta',
      'vatManagementAccounting': 'Gestione Partita IVA e Contabilità',
      'openVatNumber': 'Aprire Partita IVA',
      'openingNewVat': 'Apertura nuova partita IVA',
      'manageVatNumber': 'Gestire la Partita IVA',
      'ordinaryAccountingInvoicing': 'Contabilità ordinaria, fatturazione, registrazioni',
      'taxesContributions': 'Tasse e Contributi',
      'f24InpsTaxDeadlines': 'F24, INPS, scadenze fiscali',
      'clarificationsConsulting': 'Chiarimenti e Consulenza',
      'questionsAccountingSupport': 'Domande e supporto fiscale/contabile',
      'closeChangeActivity': 'Chiudere o Cambiare Attività',
      'businessTerminationModification': 'Cessazione o modifica attività',
      'businessType': 'Tipo di attività',
      'trade': 'Commercio',
      'servicesActivity': 'Servizi',
      'craftsmanship': 'Artigianato',
      'freelance': 'Libera professione',
      'businessDescription': 'Descrizione attività',
      'expectedTaxRegime': 'Regime fiscale previsto',
      'flatRate': 'Forfettario',
      'simplified': 'Semplificato',
      'ordinary': 'Ordinario',
      'dontKnow': 'Non so',
      'expectedAnnualRevenue': 'Fatturato annuo previsto (€)',
      'companyName': 'Nome/Ragione sociale',
      'vatNumber': 'Partita IVA',
      'supportTypeRequired': 'Tipo di supporto richiesto',
      'electronicInvoicing': 'Fatturazione elettronica',
      'invoiceRegistration': 'Registrazione fatture',
      'journalManagement': 'Gestione prima nota',
      'annualBalance': 'Bilancio annuale',
      'generalConsulting': 'Consulenza generale',
      'currentTaxRegime': 'Regime fiscale attuale',
      'describeYourNeed': 'Descrivi la tua esigenza',
      'complianceType': 'Tipo di adempimento',
      'vatPayment': 'Pagamento IVA',
      'inpsContributions': 'Contributi INPS',
      'advanceTaxes': 'Acconto imposte',
      'taxBalance': 'Saldo imposte',
      'referencePeriod': 'Periodo di riferimento',
      'quarterly': 'Trimestrale',
      'monthly': 'Mensile',
      'annual': 'Annuale',
      'description': 'Descrizione',
      'haveVatNumber': 'Hai già partita IVA?',
      'consultingTopic': 'Argomento della consulenza',
      'taxAspects': 'Aspetti fiscali',
      'contributionAspects': 'Aspetti contributivi',
      'taxRegime': 'Regime fiscale',
      'deductionsDeductions': 'Detrazioni/Deduzioni',
      'describeYourQuestion': 'Descrivi la tua domanda',
      'whatDoYouWantToDo': 'Cosa vuoi fare?',
      'closeVatNumber': 'Chiudere partita IVA',
      'changeActivity': 'Cambiare attività',
      'changeTaxRegime': 'Cambiare regime fiscale',
      'expectedDate': 'Data prevista',
      'reason': 'Motivazione',
      'selectFiscalService': 'Seleziona il servizio fiscale',
      'tax730Declaration': '730 - Dichiarazione dei Redditi',
      'tax730Description': 'Compilazione modello 730 per dipendenti e pensionati',
      'individualPerson': 'Persona Fisica',
      'individualPersonDescription': 'Dichiarazione redditi per persone fisiche',
      'taxpayerType': 'Tipologia contribuente',
      'employee': 'Lavoratore dipendente',
      'pensioner': 'Pensionato',
      'fiscalYear': 'Anno fiscale',
      'hasDeductibleExpenses': 'Hai spese detraibili/deducibili?',
      'notesAndAdditionalInfo': 'Note e informazioni aggiuntive',
      'incomeType': 'Tipologia di reddito',
      'employedWork': 'Lavoro dipendente',
      'selfEmployed': 'Lavoro autonomo',
      'pension': 'Pensione',
      'capitalIncome': 'Redditi da capitale',
      'otherIncome': 'Redditi diversi',
      'multipleTypes': 'Più tipologie',
      'hasProperties': 'Hai immobili?',
      'detailsAndNotes': 'Dettagli e note',
      'projectDescription': 'Descrizione del progetto',
      'servicesOffered': 'Servizi offerti',
      'youthCategory': 'Giovani',
      'womenCategory': 'Donne',
      'sportsCategory': 'Sport',
      'migrantsCategory': 'Migranti',
      'mafaldaDescription': 'Progetto europeo dedicato ai giovani per lo sviluppo di competenze e opportunità di mobilità internazionale.',
      'womentorDescription': 'Programma di mentoring e networking intergenerazionale tra donne per la crescita personale e professionale.',
      'sportunityDescription': 'Integrazione sociale e inclusione attraverso lo sport e attività ricreative per tutta la comunità.',
      'passaparolaDescription': 'Sportello dedicato ai migranti per supporto documentale, orientamento e integrazione sociale.',
      'mafaldaService1': 'Progettazione Europea',
      'mafaldaService2': 'Mobilità Giovanile',
      'mafaldaService3': 'Sviluppo Competenze',
      'mafaldaService4': 'Networking Europeo',
      'womentorService1': 'Mentoring Intergenerazionale',
      'womentorService2': 'Networking Femminile',
      'womentorService3': 'Formazione Leadership',
      'womentorService4': 'Empowerment Professionale',
      'sportunityService1': 'Integrazione tramite Sport',
      'sportunityService2': 'Attività Sportive Inclusive',
      'sportunityService3': 'Eventi Comunitari',
      'sportunityService4': 'Promozione Benessere',
      'passaparolaService1': 'Sportello Migranti',
      'passaparolaService2': 'Supporto Documentale',
      'passaparolaService3': 'Orientamento Legale',
      'passaparolaService4': 'Integrazione Sociale',
      'chatbotTitle': 'Assistenza & FAQ',
      'chatbotWelcome': 'Ciao! 👋 Sono l\'assistente virtuale WECOOP. Come posso aiutarti oggi?',
      'chatbotServicesResponse': 'Offriamo diversi servizi:\n\n• Accoglienza e Orientamento\n• Mediazione Fiscale\n• Supporto Contabile\n• Servizi per Migranti\n\nQuale ti interessa?',
      'chatbotProjectsResponse': 'Abbiamo 4 macro-categorie di progetti:\n\n🔵 Giovani (MAFALDA)\n🟣 Donne (WOMENTOR)\n🟢 Sport (SPORTUNITY)\n🟠 Migranti (PASSAPAROLA)\n\nVuoi saperne di più?',
      'chatbotPermitResponse': 'Ti serve il permesso di soggiorno? Possiamo aiutarti con:\n\n• Lavoro Subordinato\n• Lavoro Autonomo\n• Studio\n• Famiglia\n\nSeleziona il tipo che ti interessa.',
      'chatbotCitizenshipResponse': 'Per la cittadinanza italiana ti aiutiamo a:\n\n• Verificare i requisiti\n• Preparare la documentazione\n• Presentare la domanda\n\nVuoi iniziare la richiesta?',
      'chatbotAsylumResponse': 'Ti aiutiamo con la richiesta di protezione internazionale. È un processo delicato e ti seguiremo passo passo.\n\nVuoi iniziare?',
      'chatbotTaxResponse': 'Ti serve aiuto con il 730 o altri servizi fiscali?\n\nOffriamo:\n• Dichiarazione 730\n• Consulenza fiscale\n• Supporto contabile',
      'chatbotAppointmentResponse': 'Vuoi prenotare un appuntamento? Puoi farlo facilmente dalla nostra app!',
      'chatbotGreeting': 'Ciao! Come posso aiutarti oggi? 😊',
      'chatbotThanksResponse': 'Prego! Sono qui per aiutarti. C\'è altro che posso fare per te?',
      'chatbotDefaultResponse': 'Non sono sicuro di aver capito. Puoi dirmi:\n\n• "Servizi" per vedere i nostri servizi\n• "Progetti" per i nostri progetti\n• "Permesso di soggiorno"\n• "Cittadinanza"\n• "730" per servizi fiscali\n• "Appuntamento" per prenotare\n\nOppure seleziona una domanda qui sotto:',
      'chatbotGoToServices': 'Vai ai servizi',
      'chatbotRequestCitizenship': 'Richiedi Cittadinanza',
      'chatbotStartRequest': 'Inizia Richiesta',
      'chatbotFiscalServices': 'Servizi Fiscali',
      'chatbotBookNow': 'Prenota Ora',
      'chatbotWelcomeBtn': 'Accoglienza',
      'chatbotFiscalBtn': 'Servizi Fiscali',
      'chatbotMigrantsBtn': 'Servizi Migranti',
      'chatbotWelcomeService': 'Accoglienza e Orientamento',
      'chatbotFiscalService': 'Mediazione Fiscale',
      'chatbotMigrantsService': 'Servizi per Migranti',
      'chatbotWelcomeDetail': 'Il servizio di Accoglienza ti aiuta con orientamento e supporto iniziale. Vuoi maggiori informazioni?',
      'chatbotGoToService': 'Vai al Servizio',
      'chatbotYouthBtn': 'Giovani',
      'chatbotWomenBtn': 'Donne',
      'chatbotSportBtn': 'Sport',
      'chatbotMigrantsProjectBtn': 'Migranti',
      'chatbotYouthProjects': 'Progetti Giovani',
      'chatbotWomenProjects': 'Progetti Donne',
      'chatbotSportProjects': 'Progetti Sport',
      'chatbotMigrantsProjects': 'Progetti Migranti',
      'chatbotServicesQuick': 'Servizi',
      'chatbotProjectsQuick': 'Progetti',
      'chatbotPermitQuick': 'Permesso Soggiorno',
      'chatbotCitizenshipQuick': 'Cittadinanza',
      'chatbotAppointmentQuick': 'Appuntamento',
      'chatbotFAQTitle': '❓ Domande Frequenti (FAQ)',
      'chatbotFAQ1Question': 'Come posso richiedere il permesso di soggiorno?',
      'chatbotFAQ1Answer': 'Vai su Servizi > Servizi per Migranti > Permesso di Soggiorno e seleziona la categoria appropriata.',
      'chatbotFAQ2Question': 'Quali documenti servono per il 730?',
      'chatbotFAQ2Answer': 'Ti serviranno: CU, documenti di spesa detraibili, codice fiscale. Possiamo aiutarti nella compilazione!',
      'chatbotFAQ3Question': 'Che progetti avete per i giovani?',
      'chatbotFAQ3Answer': 'Il progetto MAFALDA offre opportunità di mobilità europea, formazione e sviluppo competenze.',
      'chatbotFAQ4Question': 'Come posso diventare socio?',
      'chatbotFAQ4Answer': 'Dal tuo profilo clicca su "Diventa Socio WECOOP" e compila il modulo di adesione.',
      'chatbotFAQ5Question': 'Come prenoto un appuntamento?',
      'chatbotFAQ5Answer': 'Puoi prenotare direttamente dall\'app cliccando su "Prenota Appuntamento".',
      'chatbotInputHint': 'Scrivi un messaggio...',
      'alreadyRegisteredLogin': 'Se sei già registrato effettua il login',
      'continueWithoutLogin': 'Continua senza loggarti',
      'alreadyRegistered': 'Sei già registrato?',
      'loginToAccess': 'Accedi per utilizzare tutti i servizi',
    },
    'en': {
      'appTitle': 'WECOOP',
      'hello': 'Hello',
      'welcome': 'Welcome to WECOOP! Explore events, services and projects near you.',
      'user': 'User',
      'profile': 'Profile',
      'home': 'Home',
      'events': 'Events',
      'calendar': 'Requests',
      'projects': 'Projects',
      'services': 'Services',
      'notifications': 'Notifications',
      'login': 'Login',
      'logout': 'Logout',
      'logoutConfirm': 'Logged out successfully',
      'email': 'Email',
      'password': 'Password',
      'memberCard': 'WECOOP Member Card',
      'cardNumber': 'Card Number',
      'openDigitalCard': 'Open digital card',
      'preferences': 'Preferences',
      'language': 'Language',
      'areaOfInterest': 'Area of interest',
      'participationHistory': 'Participation history',
      'culture': 'Culture',
      'sport': 'Sport',
      'training': 'Training',
      'volunteering': 'Volunteering',
      'socialServices': 'Social services',
      'rememberPassword': 'Remember password',
      'networkError': 'Network error',
      'upcomingEvents': 'Upcoming events',
      'activeProjects': 'Active projects',
      'quickAccess': 'Quick access',
      'communityMap': 'Community Map',
      'resourcesGuides': 'Resources & Guides',
      'localGroups': 'Local Groups',
      'forumDiscussions': 'Forum & Discussions',
      'support': 'Support',
      'ourServices': 'Our services',
      'welcomeOrientation': 'Welcome and Orientation',
      'taxMediation': 'Tax Mediation',
      'accountingSupport': 'Accounting Support',
      'latestArticles': 'Latest articles',
      'errorLoading': 'Error',
      'noArticlesAvailable': 'No articles available.',
      'myRequests': 'My Requests',
      'payNow': 'Pay Now',
      'cannotOpenPaymentLink': 'Cannot open payment link',
      'errorLoadingData': 'Loading error',
      'sportello': 'Desk',
      'digitalDesk': 'Digital Desk',
      'serviceRequest': 'Service request',
      'selectService': 'Select a service',
      'bookAppointment': 'Book Appointment',
      'chatbotSupport': 'Chatbot / Support',
      'chatbotUnavailable': 'Chatbot not available at the moment',
      'bookDigitalAppointment': 'Book Digital Appointment',
      'proposeEvent': 'Propose course or event',
      'proposeEventTitle': 'Propose a course or event',
      'featureInDevelopment': 'Feature in development.',
      'close': 'Close',
      'becomeMember': 'Become a WECOOP Member',
      'requestSent': 'Request sent!',
      'requestReceived': 'We have received your membership request. We will contact you soon to complete the process.',
      'ok': 'OK',
      'error': 'Error',
      'emailAlreadyRegistered': 'Email already registered',
      'emailExistsMessage': 'This email is already registered in our system. Do you want to login with your credentials?',
      'cancel': 'Cancel',
      'goToLogin': 'Go to Login',
      'personalInfo': 'Personal Information',
      'name': 'Name',
      'surname': 'Surname',
      'birthDate': 'Birth date',
      'dateFormat': 'dd/mm/yyyy',
      'fiscalCode': 'Tax ID',
      'contactInfo': 'Contact Information',
      'phone': 'Phone',
      'address': 'Address',
      'residenceAddress': 'Residence address',
      'city': 'City',
      'province': 'Province',
      'postalCode': 'Postal Code',
      'additionalInfo': 'Additional information',
      'additionalInfoPlaceholder': 'Any additional information',
      'privacyConsent': 'I accept the processing of personal data',
      'sendRequest': 'Send Request',
      'myEvents': 'My events',
      'notEnrolledInEvents': 'You are not enrolled in any event',
      'reload': 'Reload',
      'allEvents': 'All events',
      'cultural': 'Cultural',
      'sports': 'Sports',
      'social': 'Social',
      'retry': 'Retry',
      'noEventsAvailable': 'No events available',
      'enrolled': 'Enrolled',
      'eventConcluded': 'EVENT CONCLUDED',
      'loading': 'Loading...',
      'confirmCancellation': 'Confirm cancellation',
      'confirmCancellationMessage': 'Are you sure you want to cancel your enrollment?',
      'cancelEnrollment': 'Cancel enrollment',
      'date': 'Date',
      'end': 'End',
      'place': 'Place',
      'price': 'Price',
      'organizer': 'Organizer',
      'descriptionLabel': 'Description',
      'program': 'Program',
      'gallery': 'Gallery',
      'enrollNow': 'Enroll',
      'soldOut': 'SOLD OUT',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
      'january': 'Jan',
      'february': 'Feb',
      'march': 'Mar',
      'april': 'Apr',
      'may': 'May',
      'june': 'Jun',
      'july': 'Jul',
      'august': 'Aug',
      'september': 'Sep',
      'october': 'Oct',
      'november': 'Nov',
      'december': 'Dec',
      'online': 'Online',
      'locationToBeDefined': 'Location to be defined',
      'participants': 'participants',
      'spotsRemaining': 'spots remaining',
      'sending': 'Sending...',
      'fillAllFields': 'Fill all fields',
      'bookingConfirmed': 'Booking confirmed!',
      'connectionError': 'Connection error',
      'selectDate': 'Select a date',
      'availableSlots': 'Available slots',
      'book': 'Book',
      'selectType': 'Select type',
      'residencePermit': 'Residence Permit',
      'checkRequirements': 'Check requirements',
      'familySection': 'Family Section',
      'incomeSection': 'Income Section',
      'expensesSection': 'Expenses Section',
      'compilation730': '730 Tax Filing',
      'data730SentSuccess': '730 data sent successfully',
      'allFieldsRequired': 'Error: all fields are required',
      'fiscalData': 'Tax data',
      'incomeData': 'Income data',
      'deductions': 'Deductions',
      'send730': 'Send 730',
      'citizenshipService': 'Citizenship',
      'citizenshipIntro': 'Support service to obtain Italian citizenship',
      'citizenshipDescription': 'Fill out the questionnaire to check if you meet the necessary requirements.',
      'requirementsNotMet': 'Requirements not met',
      'requirementsMessage': 'You currently do not meet all the necessary requirements to apply for citizenship. We recommend contacting us for personalized advice.',
      'serviceNotAvailable': 'Service not available',
      'serviceNotAvailableMessage': 'This service is not yet active. Come back later or contact our support for more information.',
      'all': 'All',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'selectServiceYouNeed': 'Select the service you need',
      'guideStepByStep': 'We will guide you step by step to complete your request',
      'residencePermitDesc': 'Application, renewal and information',
      'citizenship': 'Citizenship',
      'citizenshipDesc': 'Italian citizenship application',
      'politicalAsylum': 'Political Asylum',
      'politicalAsylumDesc': 'International protection',
      'touristVisa': 'Tourist Visa',
      'touristVisaDesc': 'Tourist visa application',
      'understand': 'I understand',
      'contactUs': 'Contact us',
      'yes': 'Yes',
      'no': 'No',
      'needLogin': 'Members only service',
      'needLoginMessage': 'To access this service you must be registered as a WECOOP member.',
      'goBack': 'Go back',
      'notMemberYet': 'Not a member yet?',
      'notMemberMessage': 'To access this service you must be a WECOOP member.',
      'backToHome': 'Back to home',
      'loginToAccessServices': 'Log in to access all services reserved for members.',
      'membershipPendingApproval': 'Your membership application is pending approval.',
      'confirmationWithin24to48Hours': 'You will receive an email confirmation within 24-48 hours.',
      'onceApprovedAccessAllServices': 'Once approved, you will be able to access all services.',
      'toAccessServicesBecomeMember': 'To access {serviceName} services you must be a WECOOP member.',
      'becomeMemberToAccess': 'Become a member to access:',
      'whyBecomeMember': 'Why become a member?',
      'fiscalCodeMustBe16Chars': 'Tax ID must be 16 characters',
      'birthPlace': 'Place of Birth',
      'invalidPostalCode': 'Invalid postal code',
      'invalidEmail': 'Invalid email',
      'fillFollowingFields': 'Fill in the following fields',
      'sendingError': 'Error during submission',
      'internationalProtectionRequest': 'The international protection request is a delicate process. We will help you prepare the documentation.',
      'internationalProtection': 'International Protection',
      'fullName': 'Full name',
      'dateOfBirth': 'Date of birth',
      'countryOfOrigin': 'Country of origin',
      'dateOfArrivalInItaly': 'Date of arrival in Italy',
      'reasonForRequest': 'Reason for request',
      'politicalPersecution': 'Political persecution',
      'religiousPersecution': 'Religious persecution',
      'persecutionSexualOrientation': 'Persecution for sexual orientation',
      'war': 'War',
      'other': 'Other',
      'situationDescription': 'Situation description',
      'hasFamilyInItaly': 'Do you have family in Italy?',
      'additionalNotes': 'Additional notes',
      'startRequest': 'Start request',
      'touristVisaRequest': 'Tourist Visa Request',
      'touristVisaCategory': 'Tourist visa',
      'nationality': 'Nationality',
      'passportNumber': 'Passport number',
      'expectedArrivalDate': 'Expected arrival date',
      'expectedDepartureDate': 'Expected departure date',
      'travelReason': 'Reason for travel',
      'tourism': 'Tourism',
      'familyVisit': 'Family visit',
      'business': 'Business',
      'accommodationAddressItaly': 'Accommodation address in Italy',
      'fillRequest': 'Fill out request',
      'vatManagementAccounting': 'VAT Management and Accounting',
      'openVatNumber': 'Open VAT Number',
      'openingNewVat': 'Opening new VAT number',
      'manageVatNumber': 'Manage VAT Number',
      'ordinaryAccountingInvoicing': 'Ordinary accounting, invoicing, registrations',
      'taxesContributions': 'Taxes and Contributions',
      'f24InpsTaxDeadlines': 'F24, INPS, tax deadlines',
      'clarificationsConsulting': 'Clarifications and Consulting',
      'questionsAccountingSupport': 'Questions and tax/accounting support',
      'closeChangeActivity': 'Close or Change Activity',
      'businessTerminationModification': 'Business termination or modification',
      'businessType': 'Type of business',
      'trade': 'Trade',
      'servicesActivity': 'Services',
      'craftsmanship': 'Craftsmanship',
      'freelance': 'Freelance',
      'businessDescription': 'Business description',
      'expectedTaxRegime': 'Expected tax regime',
      'flatRate': 'Flat rate',
      'simplified': 'Simplified',
      'ordinary': 'Ordinary',
      'dontKnow': 'I don\'t know',
      'expectedAnnualRevenue': 'Expected annual revenue (€)',
      'companyName': 'Company name',
      'vatNumber': 'VAT number',
      'supportTypeRequired': 'Type of support required',
      'electronicInvoicing': 'Electronic invoicing',
      'invoiceRegistration': 'Invoice registration',
      'journalManagement': 'Journal management',
      'annualBalance': 'Annual balance',
      'generalConsulting': 'General consulting',
      'currentTaxRegime': 'Current tax regime',
      'describeYourNeed': 'Describe your need',
      'complianceType': 'Type of compliance',
      'vatPayment': 'VAT payment',
      'inpsContributions': 'INPS contributions',
      'advanceTaxes': 'Advance taxes',
      'taxBalance': 'Tax balance',
      'referencePeriod': 'Reference period',
      'quarterly': 'Quarterly',
      'monthly': 'Monthly',
      'annual': 'Annual',
      'description': 'Description',
      'haveVatNumber': 'Do you already have a VAT number?',
      'consultingTopic': 'Consulting topic',
      'taxAspects': 'Tax aspects',
      'contributionAspects': 'Contribution aspects',
      'taxRegime': 'Tax regime',
      'deductionsDeductions': 'Deductions/Deductions',
      'describeYourQuestion': 'Describe your question',
      'whatDoYouWantToDo': 'What do you want to do?',
      'closeVatNumber': 'Close VAT number',
      'changeActivity': 'Change activity',
      'changeTaxRegime': 'Change tax regime',
      'expectedDate': 'Expected date',
      'reason': 'Reason',
      'selectFiscalService': 'Select tax service',
      'tax730Declaration': '730 - Income Tax Return',
      'tax730Description': 'Form 730 preparation for employees and pensioners',
      'individualPerson': 'Individual Person',
      'individualPersonDescription': 'Income tax return for individuals',
      'taxpayerType': 'Taxpayer type',
      'employee': 'Employee',
      'pensioner': 'Pensioner',
      'fiscalYear': 'Fiscal year',
      'hasDeductibleExpenses': 'Do you have deductible expenses?',
      'notesAndAdditionalInfo': 'Notes and additional information',
      'incomeType': 'Income type',
      'employedWork': 'Employed work',
      'selfEmployed': 'Self-employed',
      'pension': 'Pension',
      'capitalIncome': 'Capital income',
      'otherIncome': 'Other income',
      'multipleTypes': 'Multiple types',
      'hasProperties': 'Has real estate properties',
      'detailsAndNotes': 'Details and notes',
      'projectDescription': 'Project description',
      'servicesOffered': 'Services offered',
      'youthCategory': 'Youth',
      'womenCategory': 'Women',
      'sportsCategory': 'Sports',
      'migrantsCategory': 'Migrants',
      'mafaldaDescription': 'European project dedicated to young people for skills development and international mobility opportunities.',
      'womentorDescription': 'Intergenerational mentoring and networking program among women for personal and professional growth.',
      'sportunityDescription': 'Social integration and inclusion through sports and recreational activities for the entire community.',
      'passaparolaDescription': 'Dedicated desk for migrants providing document support, guidance and social integration.',
      'mafaldaService1': 'European Project Design',
      'mafaldaService2': 'Youth Mobility',
      'mafaldaService3': 'Skills Development',
      'mafaldaService4': 'European Networking',
      'womentorService1': 'Intergenerational Mentoring',
      'womentorService2': 'Women\'s Networking',
      'womentorService3': 'Leadership Training',
      'womentorService4': 'Professional Empowerment',
      'sportunityService1': 'Integration through Sport',
      'sportunityService2': 'Inclusive Sport Activities',
      'sportunityService3': 'Community Events',
      'sportunityService4': 'Wellness Promotion',
      'passaparolaService1': 'Migrant Desk',
      'passaparolaService2': 'Document Support',
      'passaparolaService3': 'Legal Guidance',
      'passaparolaService4': 'Social Integration',
      'chatbotTitle': 'Assistance & FAQ',
      'chatbotWelcome': 'Hello! 👋 I\'m the WECOOP virtual assistant. How can I help you today?',
      'chatbotServicesResponse': 'We offer several services:\n\n• Welcome and Orientation\n• Tax Mediation\n• Accounting Support\n• Migrant Services\n\nWhich one interests you?',
      'chatbotProjectsResponse': 'We have 4 macro-categories of projects:\n\n🔵 Youth (MAFALDA)\n🟣 Women (WOMENTOR)\n🟢 Sport (SPORTUNITY)\n🟠 Migrants (PASSAPAROLA)\n\nWould you like to know more?',
      'chatbotPermitResponse': 'Do you need a residence permit? We can help you with:\n\n• Employed Work\n• Self-Employment\n• Study\n• Family\n\nSelect the type that interests you.',
      'chatbotCitizenshipResponse': 'For Italian citizenship we help you:\n\n• Verify requirements\n• Prepare documentation\n• Submit the application\n\nWould you like to start the request?',
      'chatbotAsylumResponse': 'We help you with the international protection request. It\'s a delicate process and we will guide you step by step.\n\nWould you like to start?',
      'chatbotTaxResponse': 'Do you need help with the 730 or other tax services?\n\nWe offer:\n• 730 Declaration\n• Tax Consulting\n• Accounting Support',
      'chatbotAppointmentResponse': 'Would you like to book an appointment? You can easily do it from our app!',
      'chatbotGreeting': 'Hello! How can I help you today? 😊',
      'chatbotThanksResponse': 'You\'re welcome! I\'m here to help. Is there anything else I can do for you?',
      'chatbotDefaultResponse': 'I\'m not sure I understood. You can tell me:\n\n• "Services" to see our services\n• "Projects" for our projects\n• "Residence permit"\n• "Citizenship"\n• "730" for tax services\n• "Appointment" to book\n\nOr select a question below:',
      'chatbotGoToServices': 'Go to services',
      'chatbotRequestCitizenship': 'Request Citizenship',
      'chatbotStartRequest': 'Start Request',
      'chatbotFiscalServices': 'Tax Services',
      'chatbotBookNow': 'Book Now',
      'chatbotWelcomeBtn': 'Welcome',
      'chatbotFiscalBtn': 'Tax Services',
      'chatbotMigrantsBtn': 'Migrant Services',
      'chatbotWelcomeService': 'Welcome and Orientation',
      'chatbotFiscalService': 'Tax Mediation',
      'chatbotMigrantsService': 'Migrant Services',
      'chatbotWelcomeDetail': 'The Welcome service helps you with orientation and initial support. Would you like more information?',
      'chatbotGoToService': 'Go to Service',
      'chatbotYouthBtn': 'Youth',
      'chatbotWomenBtn': 'Women',
      'chatbotSportBtn': 'Sport',
      'chatbotMigrantsProjectBtn': 'Migrants',
      'chatbotYouthProjects': 'Youth Projects',
      'chatbotWomenProjects': 'Women Projects',
      'chatbotSportProjects': 'Sport Projects',
      'chatbotMigrantsProjects': 'Migrant Projects',
      'chatbotServicesQuick': 'Services',
      'chatbotProjectsQuick': 'Projects',
      'chatbotPermitQuick': 'Residence Permit',
      'chatbotCitizenshipQuick': 'Citizenship',
      'chatbotAppointmentQuick': 'Appointment',
      'chatbotFAQTitle': '❓ Frequently Asked Questions (FAQ)',
      'chatbotFAQ1Question': 'How can I request a residence permit?',
      'chatbotFAQ1Answer': 'Go to Services > Migrant Services > Residence Permit and select the appropriate category.',
      'chatbotFAQ2Question': 'What documents are needed for the 730?',
      'chatbotFAQ2Answer': 'You will need: CU, deductible expense documents, tax code. We can help you with the compilation!',
      'chatbotFAQ3Question': 'What projects do you have for young people?',
      'chatbotFAQ3Answer': 'The MAFALDA project offers European mobility, training and skills development opportunities.',
      'chatbotFAQ4Question': 'How can I become a member?',
      'chatbotFAQ4Answer': 'From your profile click on "Become a WECOOP Member" and fill out the membership form.',
      'chatbotFAQ5Question': 'How do I book an appointment?',
      'chatbotFAQ5Answer': 'You can book directly from the app by clicking on "Book Appointment".',
      'chatbotInputHint': 'Write a message...',
      'alreadyRegisteredLogin': 'If you are already registered, log in',
      'continueWithoutLogin': 'Continue without logging in',
      'alreadyRegistered': 'Already registered?',
      'loginToAccess': 'Login to access all services',
    },
    'es': {
      'appTitle': 'WECOOP',
      'hello': 'Hola',
      'welcome': '¡Bienvenida a WECOOP! Explora eventos, servicios y proyectos cerca de ti.',
      'user': 'Usuario',
      'profile': 'Perfil',
      'home': 'Inicio',
      'events': 'Eventos',
      'calendar': 'Solicitudes',
      'projects': 'Proyectos',
      'services': 'Servicios',
      'notifications': 'Notificaciones',
      'login': 'Iniciar sesión',
      'logout': 'Cerrar sesión',
      'logoutConfirm': 'Sesión cerrada',
      'email': 'Correo',
      'password': 'Contraseña',
      'memberCard': 'Tarjeta de Socio WECOOP',
      'cardNumber': 'N° Tarjeta',
      'openDigitalCard': 'Abrir tarjeta digital',
      'preferences': 'Preferencias',
      'language': 'Idioma',
      'areaOfInterest': 'Área de interés',
      'participationHistory': 'Historial de participación',
      'culture': 'Cultura',
      'sport': 'Deporte',
      'training': 'Formación',
      'volunteering': 'Voluntariado',
      'socialServices': 'Servicios sociales',
      'rememberPassword': 'Recordar contraseña',
      'networkError': 'Error de red',
      'upcomingEvents': 'Próximos eventos',
      'activeProjects': 'Proyectos activos',
      'quickAccess': 'Acceso rápido',
      'communityMap': 'Mapa de la Comunidad',
      'resourcesGuides': 'Recursos y Guías',
      'localGroups': 'Grupos Locales',
      'forumDiscussions': 'Foro y Discusiones',
      'support': 'Soporte',
      'ourServices': 'Nuestros servicios',
      'welcomeOrientation': 'Acogida y Orientación',
      'taxMediation': 'Mediación Fiscal',
      'accountingSupport': 'Soporte Contable',
      'latestArticles': 'Últimos artículos',
      'errorLoading': 'Error',
      'noArticlesAvailable': 'No hay artículos disponibles.',
      'myRequests': 'Mis Solicitudes',
      'payNow': 'Pagar Ahora',
      'cannotOpenPaymentLink': 'No se puede abrir el enlace de pago',
      'errorLoadingData': 'Error al cargar',
      'sportello': 'Mostrador',
      'digitalDesk': 'Mostrador Digital',
      'serviceRequest': 'Solicitud de servicio',
      'selectService': 'Selecciona un servicio',
      'bookAppointment': 'Reservar Cita',
      'chatbotSupport': 'Chatbot / Soporte',
      'chatbotUnavailable': 'Chatbot no disponible en este momento',
      'bookDigitalAppointment': 'Reservar Cita Digital',
      'proposeEvent': 'Proponer curso o evento',
      'proposeEventTitle': 'Proponer un curso o evento',
      'featureInDevelopment': 'Funcionalidad en desarrollo.',
      'close': 'Cerrar',
      'becomeMember': 'Hacerse Socio WECOOP',
      'requestSent': '¡Solicitud enviada!',
      'requestReceived': 'Hemos recibido tu solicitud de membresía. Nos pondremos en contacto contigo pronto para completar el proceso.',
      'ok': 'OK',
      'error': 'Error',
      'emailAlreadyRegistered': 'Email ya registrado',
      'emailExistsMessage': 'Este email ya está registrado en nuestro sistema. ¿Quieres iniciar sesión con tus credenciales?',
      'cancel': 'Cancelar',
      'goToLogin': 'Ir al Login',
      'personalInfo': 'Información Personal',
      'name': 'Nombre',
      'surname': 'Apellido',
      'birthDate': 'Fecha de nacimiento',
      'dateFormat': 'dd/mm/aaaa',
      'fiscalCode': 'Código Fiscal',
      'contactInfo': 'Información de Contacto',
      'phone': 'Teléfono',
      'address': 'Dirección',
      'residenceAddress': 'Dirección de residencia',
      'city': 'Ciudad',
      'province': 'Provincia',
      'postalCode': 'Código Postal',
      'additionalInfo': 'Información adicional',
      'additionalInfoPlaceholder': 'Cualquier información adicional',
      'privacyConsent': 'Acepto el tratamiento de datos personales',
      'sendRequest': 'Enviar Solicitud',
      'myEvents': 'Mis eventos',
      'notEnrolledInEvents': 'No estás inscrito en ningún evento',
      'reload': 'Recargar',
      'allEvents': 'Todos los eventos',
      'cultural': 'Culturales',
      'sports': 'Deportivos',
      'social': 'Sociales',
      'retry': 'Reintentar',
      'noEventsAvailable': 'No hay eventos disponibles',
      'enrolled': 'Inscrito',
      'eventConcluded': 'EVENTO CONCLUIDO',
      'loading': 'Cargando...',
      'confirmCancellation': 'Confirmar cancelación',
      'confirmCancellationMessage': '¿Estás seguro de que quieres cancelar tu inscripción?',
      'cancelEnrollment': 'Cancelar inscripción',
      'date': 'Fecha',
      'end': 'Fin',
      'place': 'Lugar',
      'price': 'Precio',
      'organizer': 'Organizador',
      'descriptionLabel': 'Descripción',
      'program': 'Programa',
      'gallery': 'Galería',
      'enrollNow': 'Inscribirse',
      'soldOut': 'ENTRADAS AGOTADAS',
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mié',
      'thursday': 'Jue',
      'friday': 'Vie',
      'saturday': 'Sáb',
      'sunday': 'Dom',
      'january': 'Ene',
      'february': 'Feb',
      'march': 'Mar',
      'april': 'Abr',
      'may': 'May',
      'june': 'Jun',
      'july': 'Jul',
      'august': 'Ago',
      'september': 'Sep',
      'october': 'Oct',
      'november': 'Nov',
      'december': 'Dic',
      'online': 'En línea',
      'locationToBeDefined': 'Lugar por definir',
      'participants': 'participantes',
      'spotsRemaining': 'lugares restantes',
      'sending': 'Enviando...',
      'fillAllFields': 'Completa todos los campos',
      'bookingConfirmed': '¡Reserva confirmada!',
      'connectionError': 'Error de conexión',
      'selectDate': 'Selecciona una fecha',
      'availableSlots': 'Horarios disponibles',
      'book': 'Reservar',
      'selectType': 'Selecciona el tipo',
      'residencePermit': 'Permiso de Residencia',
      'checkRequirements': 'Verificar requisitos',
      'familySection': 'Sección Familia',
      'incomeSection': 'Sección Ingresos',
      'expensesSection': 'Sección Gastos',
      'compilation730': 'Compilación 730',
      'data730SentSuccess': 'Datos 730 enviados con éxito',
      'allFieldsRequired': 'Error: todos los campos son obligatorios',
      'fiscalData': 'Datos fiscales',
      'incomeData': 'Datos de ingresos',
      'deductions': 'Deducciones',
      'send730': 'Enviar 730',
      'citizenshipService': 'Ciudadanía',
      'citizenshipIntro': 'Servicio de apoyo para obtener la ciudadanía italiana',
      'citizenshipDescription': 'Completa el cuestionario para verificar si cumples con los requisitos necesarios.',
      'requirementsNotMet': 'Requisitos no cumplidos',
      'requirementsMessage': 'Actualmente no cumples con todos los requisitos necesarios para solicitar la ciudadanía. Te recomendamos contactarnos para asesoramiento personalizado.',
      'serviceNotAvailable': 'Servicio no disponible',
      'serviceNotAvailableMessage': 'Este servicio aún no está activo. Vuelve más tarde o contacta a nuestro soporte para más información.',
      'all': 'Todos',
      'pending': 'Pendiente',
      'approved': 'Aprobado',
      'rejected': 'Rechazado',
      'selectServiceYouNeed': 'Selecciona el servicio que necesitas',
      'guideStepByStep': 'Te guiaremos paso a paso para completar tu solicitud',
      'residencePermitDesc': 'Solicitud, renovación e información',
      'citizenship': 'Ciudadanía',
      'citizenshipDesc': 'Solicitud de ciudadanía italiana',
      'politicalAsylum': 'Asilo Político',
      'politicalAsylumDesc': 'Protección internacional',
      'touristVisa': 'Visa de Turismo',
      'touristVisaDesc': 'Solicitud de visa turística',
      'understand': 'Entiendo',
      'contactUs': 'Contáctanos',
      'yes': 'Sí',
      'no': 'No',
      'needLogin': 'Servicio exclusivo para socios',
      'needLoginMessage': 'Para acceder a este servicio debes estar registrado como socio WECOOP.',
      'goBack': 'Volver',
      'notMemberYet': '¿Aún no eres socio?',
      'notMemberMessage': 'Para acceder a este servicio debes ser socio de WECOOP.',
      'backToHome': 'Volver al inicio',
      'loginToAccessServices': 'Inicia sesión para acceder a todos los servicios reservados para socios.',
      'membershipPendingApproval': 'Tu solicitud de membresía está pendiente de aprobación.',
      'confirmationWithin24to48Hours': 'Recibirás una confirmación por email dentro de 24-48 horas.',
      'onceApprovedAccessAllServices': 'Una vez aprobada, podrás acceder a todos los servicios.',
      'toAccessServicesBecomeMember': 'Para acceder a los servicios de {serviceName} debes ser socio de WECOOP.',
      'becomeMemberToAccess': 'Hazte socio para acceder a:',
      'whyBecomeMember': '¿Por qué hacerse socio?',
      'operationCompleted': 'Operación completada',
      'fiscalCodeMustBe16Chars': 'El código fiscal debe tener 16 caracteres',
      'birthPlace': 'Lugar de Nacimiento',
      'invalidPostalCode': 'Código postal no válido',
      'invalidEmail': 'Email no válido',
      'fillFollowingFields': 'Completa los siguientes campos',
      'sendingError': 'Error durante el envío',
      'internationalProtectionRequest': 'La solicitud de protección internacional es un proceso delicado. Te ayudaremos a preparar la documentación.',
      'internationalProtection': 'Protección Internacional',
      'fullName': 'Nombre completo',
      'dateOfBirth': 'Fecha de nacimiento',
      'countryOfOrigin': 'País de origen',
      'dateOfArrivalInItaly': 'Fecha de llegada a Italia',
      'reasonForRequest': 'Motivo de la solicitud',
      'politicalPersecution': 'Persecución política',
      'religiousPersecution': 'Persecución religiosa',
      'persecutionSexualOrientation': 'Persecución por orientación sexual',
      'war': 'Guerra',
      'other': 'Otro',
      'situationDescription': 'Descripción de la situación',
      'hasFamilyInItaly': '¿Tienes familia en Italia?',
      'additionalNotes': 'Notas adicionales',
      'startRequest': 'Iniciar solicitud',
      'touristVisaRequest': 'Solicitud de Visa Turística',
      'touristVisaCategory': 'Visa turística',
      'nationality': 'Nacionalidad',
      'passportNumber': 'Número de pasaporte',
      'expectedArrivalDate': 'Fecha de llegada prevista',
      'expectedDepartureDate': 'Fecha de salida prevista',
      'travelReason': 'Motivo del viaje',
      'tourism': 'Turismo',
      'familyVisit': 'Visita familiar',
      'business': 'Negocios',
      'accommodationAddressItaly': 'Dirección de alojamiento en Italia',
      'fillRequest': 'Completar solicitud',
      'vatManagementAccounting': 'Gestión de IVA y Contabilidad',
      'openVatNumber': 'Abrir Número de IVA',
      'openingNewVat': 'Apertura de nuevo número de IVA',
      'manageVatNumber': 'Gestionar Número de IVA',
      'ordinaryAccountingInvoicing': 'Contabilidad ordinaria, facturación, registros',
      'taxesContributions': 'Impuestos y Contribuciones',
      'f24InpsTaxDeadlines': 'F24, INPS, plazos fiscales',
      'clarificationsConsulting': 'Aclaraciones y Consultoría',
      'questionsAccountingSupport': 'Preguntas y soporte fiscal/contable',
      'closeChangeActivity': 'Cerrar o Cambiar Actividad',
      'businessTerminationModification': 'Cese o modificación de actividad',
      'businessType': 'Tipo de actividad',
      'trade': 'Comercio',
      'servicesActivity': 'Servicios',
      'craftsmanship': 'Artesanía',
      'freelance': 'Profesión libre',
      'businessDescription': 'Descripción de la actividad',
      'expectedTaxRegime': 'Régimen fiscal previsto',
      'flatRate': 'Forfetario',
      'simplified': 'Simplificado',
      'ordinary': 'Ordinario',
      'dontKnow': 'No lo sé',
      'expectedAnnualRevenue': 'Facturación anual prevista (€)',
      'companyName': 'Nombre/Razón social',
      'vatNumber': 'Número de IVA',
      'supportTypeRequired': 'Tipo de soporte requerido',
      'electronicInvoicing': 'Facturación electrónica',
      'invoiceRegistration': 'Registro de facturas',
      'journalManagement': 'Gestión de libro diario',
      'annualBalance': 'Balance anual',
      'generalConsulting': 'Consultoría general',
      'currentTaxRegime': 'Régimen fiscal actual',
      'describeYourNeed': 'Describe tu necesidad',
      'complianceType': 'Tipo de cumplimiento',
      'vatPayment': 'Pago de IVA',
      'inpsContributions': 'Contribuciones INPS',
      'advanceTaxes': 'Anticipo de impuestos',
      'taxBalance': 'Saldo de impuestos',
      'referencePeriod': 'Período de referencia',
      'quarterly': 'Trimestral',
      'monthly': 'Mensual',
      'annual': 'Anual',
      'description': 'Descripción',
      'haveVatNumber': '¿Ya tienes número de IVA?',
      'consultingTopic': 'Tema de consultoría',
      'taxAspects': 'Aspectos fiscales',
      'contributionAspects': 'Aspectos contributivos',
      'taxRegime': 'Régimen fiscal',
      'deductionsDeductions': 'Deducciones/Deducciones',
      'describeYourQuestion': 'Describe tu pregunta',
      'whatDoYouWantToDo': '¿Qué quieres hacer?',
      'closeVatNumber': 'Cerrar número de IVA',
      'changeActivity': 'Cambiar actividad',
      'changeTaxRegime': 'Cambiar régimen fiscal',
      'expectedDate': 'Fecha prevista',
      'reason': 'Motivo',
      'selectFiscalService': 'Selecciona el servicio fiscal',
      'tax730Declaration': '730 - Declaración de la Renta',
      'tax730Description': 'Preparación del modelo 730 para empleados y pensionistas',
      'individualPerson': 'Persona Física',
      'individualPersonDescription': 'Declaración de la renta para personas físicas',
      'taxpayerType': 'Tipo de contribuyente',
      'employee': 'Trabajador empleado',
      'pensioner': 'Pensionista',
      'fiscalYear': 'Año fiscal',
      'hasDeductibleExpenses': '¿Tienes gastos deducibles?',
      'notesAndAdditionalInfo': 'Notas e información adicional',
      'incomeType': 'Tipo de ingresos',
      'employedWork': 'Trabajo empleado',
      'selfEmployed': 'Autónomo',
      'pension': 'Pensión',
      'capitalIncome': 'Ingresos de capital',
      'otherIncome': 'Otros ingresos',
      'multipleTypes': 'Múltiples tipos',
      'hasProperties': 'Tiene propiedades inmobiliarias',
      'detailsAndNotes': 'Detalles y notas',
      'projectDescription': 'Descripción del proyecto',
      'servicesOffered': 'Servicios ofrecidos',
      'youthCategory': 'Jóvenes',
      'womenCategory': 'Mujeres',
      'sportsCategory': 'Deportes',
      'migrantsCategory': 'Migrantes',
      'mafaldaDescription': 'Proyecto europeo dedicado a los jóvenes para el desarrollo de competencias y oportunidades de movilidad internacional.',
      'womentorDescription': 'Programa de mentoría y networking intergeneracional entre mujeres para el crecimiento personal y profesional.',
      'sportunityDescription': 'Integración social e inclusión a través del deporte y actividades recreativas para toda la comunidad.',
      'passaparolaDescription': 'Oficina dedicada a los migrantes para apoyo documental, orientación e integración social.',
      'mafaldaService1': 'Diseño de Proyectos Europeos',
      'mafaldaService2': 'Movilidad Juvenil',
      'mafaldaService3': 'Desarrollo de Competencias',
      'mafaldaService4': 'Networking Europeo',
      'womentorService1': 'Mentoría Intergeneracional',
      'womentorService2': 'Networking Femenino',
      'womentorService3': 'Formación en Liderazgo',
      'womentorService4': 'Empoderamiento Profesional',
      'sportunityService1': 'Integración a través del Deporte',
      'sportunityService2': 'Actividades Deportivas Inclusivas',
      'sportunityService3': 'Eventos Comunitarios',
      'sportunityService4': 'Promoción del Bienestar',
      'passaparolaService1': 'Oficina de Migrantes',
      'passaparolaService2': 'Apoyo Documental',
      'passaparolaService3': 'Orientación Legal',
      'passaparolaService4': 'Integración Social',
      'chatbotTitle': 'Asistencia & FAQ',
      'chatbotWelcome': '¡Hola! 👋 Soy el asistente virtual de WECOOP. ¿Cómo puedo ayudarte hoy?',
      'chatbotServicesResponse': 'Ofrecemos varios servicios:\n\n• Acogida y Orientación\n• Mediación Fiscal\n• Apoyo Contable\n• Servicios para Migrantes\n\n¿Cuál te interesa?',
      'chatbotProjectsResponse': 'Tenemos 4 macro-categorías de proyectos:\n\n🔵 Jóvenes (MAFALDA)\n🟣 Mujeres (WOMENTOR)\n🟢 Deporte (SPORTUNITY)\n🟠 Migrantes (PASSAPAROLA)\n\n¿Quieres saber más?',
      'chatbotPermitResponse': '¿Necesitas el permiso de residencia? Podemos ayudarte con:\n\n• Trabajo Subordinado\n• Trabajo Autónomo\n• Estudio\n• Familia\n\nSelecciona el tipo que te interesa.',
      'chatbotCitizenshipResponse': 'Para la ciudadanía italiana te ayudamos a:\n\n• Verificar los requisitos\n• Preparar la documentación\n• Presentar la solicitud\n\n¿Quieres iniciar la solicitud?',
      'chatbotAsylumResponse': 'Te ayudamos con la solicitud de protección internacional. Es un proceso delicado y te guiaremos paso a paso.\n\n¿Quieres empezar?',
      'chatbotTaxResponse': '¿Necesitas ayuda con el 730 u otros servicios fiscales?\n\nOfrecemos:\n• Declaración 730\n• Consultoría fiscal\n• Apoyo contable',
      'chatbotAppointmentResponse': '¿Quieres reservar una cita? ¡Puedes hacerlo fácilmente desde nuestra app!',
      'chatbotGreeting': '¡Hola! ¿Cómo puedo ayudarte hoy? 😊',
      'chatbotThanksResponse': '¡De nada! Estoy aquí para ayudarte. ¿Hay algo más que pueda hacer por ti?',
      'chatbotDefaultResponse': 'No estoy seguro de haber entendido. Puedes decirme:\n\n• "Servicios" para ver nuestros servicios\n• "Proyectos" para nuestros proyectos\n• "Permiso de residencia"\n• "Ciudadanía"\n• "730" para servicios fiscales\n• "Cita" para reservar\n\nO selecciona una pregunta a continuación:',
      'chatbotGoToServices': 'Ir a servicios',
      'chatbotRequestCitizenship': 'Solicitar Ciudadanía',
      'chatbotStartRequest': 'Iniciar Solicitud',
      'chatbotFiscalServices': 'Servicios Fiscales',
      'chatbotBookNow': 'Reservar Ahora',
      'chatbotWelcomeBtn': 'Acogida',
      'chatbotFiscalBtn': 'Servicios Fiscales',
      'chatbotMigrantsBtn': 'Servicios para Migrantes',
      'chatbotWelcomeService': 'Acogida y Orientación',
      'chatbotFiscalService': 'Mediación Fiscal',
      'chatbotMigrantsService': 'Servicios para Migrantes',
      'chatbotWelcomeDetail': 'El servicio de Acogida te ayuda con orientación y apoyo inicial. ¿Quieres más información?',
      'chatbotGoToService': 'Ir al Servicio',
      'chatbotYouthBtn': 'Jóvenes',
      'chatbotWomenBtn': 'Mujeres',
      'chatbotSportBtn': 'Deporte',
      'chatbotMigrantsProjectBtn': 'Migrantes',
      'chatbotYouthProjects': 'Proyectos para Jóvenes',
      'chatbotWomenProjects': 'Proyectos para Mujeres',
      'chatbotSportProjects': 'Proyectos Deportivos',
      'chatbotMigrantsProjects': 'Proyectos para Migrantes',
      'chatbotServicesQuick': 'Servicios',
      'chatbotProjectsQuick': 'Proyectos',
      'chatbotPermitQuick': 'Permiso de Residencia',
      'chatbotCitizenshipQuick': 'Ciudadanía',
      'chatbotAppointmentQuick': 'Cita',
      'chatbotFAQTitle': '❓ Preguntas Frecuentes (FAQ)',
      'chatbotFAQ1Question': '¿Cómo puedo solicitar el permiso de residencia?',
      'chatbotFAQ1Answer': 'Ve a Servicios > Servicios para Migrantes > Permiso de Residencia y selecciona la categoría apropiada.',
      'chatbotFAQ2Question': '¿Qué documentos se necesitan para el 730?',
      'chatbotFAQ2Answer': 'Necesitarás: CU, documentos de gastos deducibles, código fiscal. ¡Podemos ayudarte con la compilación!',
      'chatbotFAQ3Question': '¿Qué proyectos tienen para jóvenes?',
      'chatbotFAQ3Answer': 'El proyecto MAFALDA ofrece oportunidades de movilidad europea, formación y desarrollo de competencias.',
      'chatbotFAQ4Question': '¿Cómo puedo hacerme socio?',
      'chatbotFAQ4Answer': 'Desde tu perfil haz clic en "Hazte Socio de WECOOP" y completa el formulario de adhesión.',
      'chatbotFAQ5Question': '¿Cómo reservo una cita?',
      'chatbotFAQ5Answer': 'Puedes reservar directamente desde la app haciendo clic en "Reservar Cita".',
      'chatbotInputHint': 'Escribe un mensaje...',
      'alreadyRegisteredLogin': 'Si ya estás registrado, inicia sesión',
      'continueWithoutLogin': 'Continuar sin iniciar sesión',
      'alreadyRegistered': '¿Ya estás registrado?',
      'loginToAccess': 'Inicia sesión para acceder a todos los servicios',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for easy access
  String get appTitle => translate('appTitle');
  String get hello => translate('hello');
  String get welcome => translate('welcome');
  String get user => translate('user');
  String get profile => translate('profile');
  String get home => translate('home');
  String get events => translate('events');
  String get calendar => translate('calendar');
  String get projects => translate('projects');
  String get services => translate('services');
  String get notifications => translate('notifications');
  String get login => translate('login');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logoutConfirm');
  String get email => translate('email');
  String get password => translate('password');
  String get memberCard => translate('memberCard');
  String get cardNumber => translate('cardNumber');
  String get openDigitalCard => translate('openDigitalCard');
  String get preferences => translate('preferences');
  String get language => translate('language');
  String get areaOfInterest => translate('areaOfInterest');
  String get participationHistory => translate('participationHistory');
  String get culture => translate('culture');
  String get sport => translate('sport');
  String get training => translate('training');
  String get volunteering => translate('volunteering');
  String get socialServices => translate('socialServices');
  String get rememberPassword => translate('rememberPassword');
  String get networkError => translate('networkError');
  String get upcomingEvents => translate('upcomingEvents');
  String get activeProjects => translate('activeProjects');
  String get quickAccess => translate('quickAccess');
  String get communityMap => translate('communityMap');
  String get resourcesGuides => translate('resourcesGuides');
  String get localGroups => translate('localGroups');
  String get forumDiscussions => translate('forumDiscussions');
  String get support => translate('support');
  String get ourServices => translate('ourServices');
  String get welcomeOrientation => translate('welcomeOrientation');
  String get taxMediation => translate('taxMediation');
  String get accountingSupport => translate('accountingSupport');
  String get latestArticles => translate('latestArticles');
  String get errorLoading => translate('errorLoading');
  String get noArticlesAvailable => translate('noArticlesAvailable');
  String get myRequests => translate('myRequests');
  String get payNow => translate('payNow');
  String get cannotOpenPaymentLink => translate('cannotOpenPaymentLink');
  String get errorLoadingData => translate('errorLoadingData');
  String get sportello => translate('sportello');
  String get digitalDesk => translate('digitalDesk');
  String get serviceRequest => translate('serviceRequest');
  String get selectService => translate('selectService');
  String get bookAppointment => translate('bookAppointment');
  String get chatbotSupport => translate('chatbotSupport');
  String get chatbotUnavailable => translate('chatbotUnavailable');
  String get bookDigitalAppointment => translate('bookDigitalAppointment');
  String get proposeEvent => translate('proposeEvent');
  String get proposeEventTitle => translate('proposeEventTitle');
  String get featureInDevelopment => translate('featureInDevelopment');
  String get close => translate('close');
  String get becomeMember => translate('becomeMember');
  String get requestSent => translate('requestSent');
  String get requestReceived => translate('requestReceived');
  String get ok => translate('ok');
  String get error => translate('error');
  String get emailAlreadyRegistered => translate('emailAlreadyRegistered');
  String get emailExistsMessage => translate('emailExistsMessage');
  String get cancel => translate('cancel');
  String get goToLogin => translate('goToLogin');
  String get personalInfo => translate('personalInfo');
  String get name => translate('name');
  String get surname => translate('surname');
  String get birthDate => translate('birthDate');
  String get dateFormat => translate('dateFormat');
  String get fiscalCode => translate('fiscalCode');
  String get contactInfo => translate('contactInfo');
  String get phone => translate('phone');
  String get address => translate('address');
  String get residenceAddress => translate('residenceAddress');
  String get city => translate('city');
  String get province => translate('province');
  String get postalCode => translate('postalCode');
  String get additionalInfo => translate('additionalInfo');
  String get additionalInfoPlaceholder => translate('additionalInfoPlaceholder');
  String get privacyConsent => translate('privacyConsent');
  String get sendRequest => translate('sendRequest');
  String get myEvents => translate('myEvents');
  String get notEnrolledInEvents => translate('notEnrolledInEvents');
  String get reload => translate('reload');
  String get allEvents => translate('allEvents');
  String get cultural => translate('cultural');
  String get sports => translate('sports');
  String get social => translate('social');
  String get retry => translate('retry');
  String get noEventsAvailable => translate('noEventsAvailable');
  String get enrolled => translate('enrolled');
  String get eventConcluded => translate('eventConcluded');
  String get online => translate('online');
  String get locationToBeDefined => translate('locationToBeDefined');
  String get participants => translate('participants');
  String get spotsRemaining => translate('spotsRemaining');
  String get sending => translate('sending');
  String get fillAllFields => translate('fillAllFields');
  String get bookingConfirmed => translate('bookingConfirmed');
  String get connectionError => translate('connectionError');
  String get selectDate => translate('selectDate');
  String get availableSlots => translate('availableSlots');
  String get book => translate('book');
  String get compilation730 => translate('compilation730');
  String get data730SentSuccess => translate('data730SentSuccess');
  String get allFieldsRequired => translate('allFieldsRequired');
  String get fiscalData => translate('fiscalData');
  String get incomeData => translate('incomeData');
  String get deductions => translate('deductions');
  String get send730 => translate('send730');
  String get citizenshipService => translate('citizenshipService');
  String get citizenshipIntro => translate('citizenshipIntro');
  String get citizenshipDescription => translate('citizenshipDescription');
  String get requirementsNotMet => translate('requirementsNotMet');
  String get requirementsMessage => translate('requirementsMessage');
  String get understand => translate('understand');
  String get contactUs => translate('contactUs');
  String get yes => translate('yes');
  String get no => translate('no');
  String get needLogin => translate('needLogin');
  String get needLoginMessage => translate('needLoginMessage');
  String get goBack => translate('goBack');
  String get notMemberYet => translate('notMemberYet');
  String get notMemberMessage => translate('notMemberMessage');
  String get backToHome => translate('backToHome');
  String get serviceNotAvailable => translate('serviceNotAvailable');
  String get serviceNotAvailableMessage => translate('serviceNotAvailableMessage');
  String get all => translate('all');
  String get pending => translate('pending');
  String get approved => translate('approved');
  String get rejected => translate('rejected');
  String get selectServiceYouNeed => translate('selectServiceYouNeed');
  String get guideStepByStep => translate('guideStepByStep');
  String get residencePermit => translate('residencePermit');
  String get residencePermitDesc => translate('residencePermitDesc');
  String get citizenship => translate('citizenship');
  String get citizenshipDesc => translate('citizenshipDesc');
  String get politicalAsylum => translate('politicalAsylum');
  String get politicalAsylumDesc => translate('politicalAsylumDesc');
  String get touristVisa => translate('touristVisa');
  String get touristVisaDesc => translate('touristVisaDesc');
  String get loginToAccessServices => translate('loginToAccessServices');
  String get membershipPendingApproval => translate('membershipPendingApproval');
  String get confirmationWithin24to48Hours => translate('confirmationWithin24to48Hours');
  String get onceApprovedAccessAllServices => translate('onceApprovedAccessAllServices');
  String get toAccessServicesBecomeMember => translate('toAccessServicesBecomeMember');
  String get becomeMemberToAccess => translate('becomeMemberToAccess');
  String get whyBecomeMember => translate('whyBecomeMember');
  String get operationCompleted => translate('operationCompleted');
  String get fiscalCodeMustBe16Chars => translate('fiscalCodeMustBe16Chars');
  String get birthPlace => translate('birthPlace');
  String get invalidPostalCode => translate('invalidPostalCode');
  String get invalidEmail => translate('invalidEmail');
  String get fillFollowingFields => translate('fillFollowingFields');
  String get sendingError => translate('sendingError');
  String get internationalProtectionRequest => translate('internationalProtectionRequest');
  String get internationalProtection => translate('internationalProtection');
  String get fullName => translate('fullName');
  String get dateOfBirth => translate('dateOfBirth');
  String get countryOfOrigin => translate('countryOfOrigin');
  String get dateOfArrivalInItaly => translate('dateOfArrivalInItaly');
  String get reasonForRequest => translate('reasonForRequest');
  String get politicalPersecution => translate('politicalPersecution');
  String get religiousPersecution => translate('religiousPersecution');
  String get persecutionSexualOrientation => translate('persecutionSexualOrientation');
  String get war => translate('war');
  String get other => translate('other');
  String get situationDescription => translate('situationDescription');
  String get hasFamilyInItaly => translate('hasFamilyInItaly');
  String get additionalNotes => translate('additionalNotes');
  String get startRequest => translate('startRequest');
  String get touristVisaRequest => translate('touristVisaRequest');
  String get touristVisaCategory => translate('touristVisaCategory');
  String get nationality => translate('nationality');
  String get passportNumber => translate('passportNumber');
  String get expectedArrivalDate => translate('expectedArrivalDate');
  String get expectedDepartureDate => translate('expectedDepartureDate');
  String get travelReason => translate('travelReason');
  String get tourism => translate('tourism');
  String get familyVisit => translate('familyVisit');
  String get business => translate('business');
  String get accommodationAddressItaly => translate('accommodationAddressItaly');
  String get fillRequest => translate('fillRequest');
  String get vatManagementAccounting => translate('vatManagementAccounting');
  String get openVatNumber => translate('openVatNumber');
  String get openingNewVat => translate('openingNewVat');
  String get manageVatNumber => translate('manageVatNumber');
  String get ordinaryAccountingInvoicing => translate('ordinaryAccountingInvoicing');
  String get taxesContributions => translate('taxesContributions');
  String get f24InpsTaxDeadlines => translate('f24InpsTaxDeadlines');
  String get clarificationsConsulting => translate('clarificationsConsulting');
  String get questionsAccountingSupport => translate('questionsAccountingSupport');
  String get closeChangeActivity => translate('closeChangeActivity');
  String get businessTerminationModification => translate('businessTerminationModification');
  String get businessType => translate('businessType');
  String get trade => translate('trade');
  String get servicesActivity => translate('servicesActivity');
  String get craftsmanship => translate('craftsmanship');
  String get freelance => translate('freelance');
  String get businessDescription => translate('businessDescription');
  String get expectedTaxRegime => translate('expectedTaxRegime');
  String get flatRate => translate('flatRate');
  String get simplified => translate('simplified');
  String get ordinary => translate('ordinary');
  String get dontKnow => translate('dontKnow');
  String get expectedAnnualRevenue => translate('expectedAnnualRevenue');
  String get companyName => translate('companyName');
  String get vatNumber => translate('vatNumber');
  String get supportTypeRequired => translate('supportTypeRequired');
  String get electronicInvoicing => translate('electronicInvoicing');
  String get invoiceRegistration => translate('invoiceRegistration');
  String get journalManagement => translate('journalManagement');
  String get annualBalance => translate('annualBalance');
  String get generalConsulting => translate('generalConsulting');
  String get currentTaxRegime => translate('currentTaxRegime');
  String get describeYourNeed => translate('describeYourNeed');
  String get complianceType => translate('complianceType');
  String get vatPayment => translate('vatPayment');
  String get inpsContributions => translate('inpsContributions');
  String get advanceTaxes => translate('advanceTaxes');
  String get taxBalance => translate('taxBalance');
  String get referencePeriod => translate('referencePeriod');
  String get quarterly => translate('quarterly');
  String get monthly => translate('monthly');
  String get annual => translate('annual');
  String get description => translate('description');
  String get haveVatNumber => translate('haveVatNumber');
  String get consultingTopic => translate('consultingTopic');
  String get taxAspects => translate('taxAspects');
  String get contributionAspects => translate('contributionAspects');
  String get taxRegime => translate('taxRegime');
  String get deductionsDeductions => translate('deductionsDeductions');
  String get describeYourQuestion => translate('describeYourQuestion');
  String get whatDoYouWantToDo => translate('whatDoYouWantToDo');
  String get closeVatNumber => translate('closeVatNumber');
  String get changeActivity => translate('changeActivity');
  String get changeTaxRegime => translate('changeTaxRegime');
  String get expectedDate => translate('expectedDate');
  String get reason => translate('reason');
  String get selectFiscalService => translate('selectFiscalService');
  String get tax730Declaration => translate('tax730Declaration');
  String get tax730Description => translate('tax730Description');
  String get individualPerson => translate('individualPerson');
  String get individualPersonDescription => translate('individualPersonDescription');
  String get taxpayerType => translate('taxpayerType');
  String get employee => translate('employee');
  String get pensioner => translate('pensioner');
  String get fiscalYear => translate('fiscalYear');
  String get hasDeductibleExpenses => translate('hasDeductibleExpenses');
  String get notesAndAdditionalInfo => translate('notesAndAdditionalInfo');
  String get incomeType => translate('incomeType');
  String get employedWork => translate('employedWork');
  String get selfEmployed => translate('selfEmployed');
  String get pension => translate('pension');
  String get capitalIncome => translate('capitalIncome');
  String get otherIncome => translate('otherIncome');
  String get multipleTypes => translate('multipleTypes');
  String get hasProperties => translate('hasProperties');
  String get detailsAndNotes => translate('detailsAndNotes');
  String get projectDescription => translate('projectDescription');
  String get servicesOffered => translate('servicesOffered');
  String get youthCategory => translate('youthCategory');
  String get womenCategory => translate('womenCategory');
  String get sportsCategory => translate('sportsCategory');
  String get migrantsCategory => translate('migrantsCategory');
  String get mafaldaDescription => translate('mafaldaDescription');
  String get womentorDescription => translate('womentorDescription');
  String get sportunityDescription => translate('sportunityDescription');
  String get passaparolaDescription => translate('passaparolaDescription');
  String get mafaldaService1 => translate('mafaldaService1');
  String get mafaldaService2 => translate('mafaldaService2');
  String get mafaldaService3 => translate('mafaldaService3');
  String get mafaldaService4 => translate('mafaldaService4');
  String get womentorService1 => translate('womentorService1');
  String get womentorService2 => translate('womentorService2');
  String get womentorService3 => translate('womentorService3');
  String get womentorService4 => translate('womentorService4');
  String get sportunityService1 => translate('sportunityService1');
  String get sportunityService2 => translate('sportunityService2');
  String get sportunityService3 => translate('sportunityService3');
  String get sportunityService4 => translate('sportunityService4');
  String get passaparolaService1 => translate('passaparolaService1');
  String get passaparolaService2 => translate('passaparolaService2');
  String get passaparolaService3 => translate('passaparolaService3');
  String get passaparolaService4 => translate('passaparolaService4');
  
  // Event detail translations
  String get loading => translate('loading');
  String get confirmCancellation => translate('confirmCancellation');
  String get confirmCancellationMessage => translate('confirmCancellationMessage');
  String get cancelEnrollment => translate('cancelEnrollment');
  String get date => translate('date');
  String get end => translate('end');
  String get place => translate('place');
  String get price => translate('price');
  String get organizer => translate('organizer');
  String get descriptionLabel => translate('descriptionLabel');
  String get program => translate('program');
  String get gallery => translate('gallery');
  String get enrollNow => translate('enrollNow');
  String get soldOut => translate('soldOut');
  String get monday => translate('monday');
  String get tuesday => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday => translate('thursday');
  String get friday => translate('friday');
  String get saturday => translate('saturday');
  String get sunday => translate('sunday');
  String get january => translate('january');
  String get february => translate('february');
  String get march => translate('march');
  String get april => translate('april');
  String get may => translate('may');
  String get june => translate('june');
  String get july => translate('july');
  String get august => translate('august');
  String get september => translate('september');
  String get october => translate('october');
  String get november => translate('november');
  String get december => translate('december');
  String get selectType => translate('selectType');
  String get checkRequirements => translate('checkRequirements');
  String get familySection => translate('familySection');
  String get incomeSection => translate('incomeSection');
  String get expensesSection => translate('expensesSection');
  
  // Chatbot translations
  String get chatbotTitle => translate('chatbotTitle');
  String get chatbotWelcome => translate('chatbotWelcome');
  String get chatbotServicesResponse => translate('chatbotServicesResponse');
  String get chatbotProjectsResponse => translate('chatbotProjectsResponse');
  String get chatbotPermitResponse => translate('chatbotPermitResponse');
  String get chatbotCitizenshipResponse => translate('chatbotCitizenshipResponse');
  String get chatbotAsylumResponse => translate('chatbotAsylumResponse');
  String get chatbotTaxResponse => translate('chatbotTaxResponse');
  String get chatbotAppointmentResponse => translate('chatbotAppointmentResponse');
  String get chatbotGreeting => translate('chatbotGreeting');
  String get chatbotThanksResponse => translate('chatbotThanksResponse');
  String get chatbotDefaultResponse => translate('chatbotDefaultResponse');
  String get chatbotGoToServices => translate('chatbotGoToServices');
  String get chatbotRequestCitizenship => translate('chatbotRequestCitizenship');
  String get chatbotStartRequest => translate('chatbotStartRequest');
  String get chatbotFiscalServices => translate('chatbotFiscalServices');
  String get chatbotBookNow => translate('chatbotBookNow');
  String get chatbotWelcomeBtn => translate('chatbotWelcomeBtn');
  String get chatbotFiscalBtn => translate('chatbotFiscalBtn');
  String get chatbotMigrantsBtn => translate('chatbotMigrantsBtn');
  String get chatbotWelcomeService => translate('chatbotWelcomeService');
  String get chatbotFiscalService => translate('chatbotFiscalService');
  String get chatbotMigrantsService => translate('chatbotMigrantsService');
  String get chatbotWelcomeDetail => translate('chatbotWelcomeDetail');
  String get chatbotGoToService => translate('chatbotGoToService');
  String get chatbotYouthBtn => translate('chatbotYouthBtn');
  String get chatbotWomenBtn => translate('chatbotWomenBtn');
  String get chatbotSportBtn => translate('chatbotSportBtn');
  String get chatbotMigrantsProjectBtn => translate('chatbotMigrantsProjectBtn');
  String get chatbotYouthProjects => translate('chatbotYouthProjects');
  String get chatbotWomenProjects => translate('chatbotWomenProjects');
  String get chatbotSportProjects => translate('chatbotSportProjects');
  String get chatbotMigrantsProjects => translate('chatbotMigrantsProjects');
  String get chatbotServicesQuick => translate('chatbotServicesQuick');
  String get chatbotProjectsQuick => translate('chatbotProjectsQuick');
  String get chatbotPermitQuick => translate('chatbotPermitQuick');
  String get chatbotCitizenshipQuick => translate('chatbotCitizenshipQuick');
  String get chatbotAppointmentQuick => translate('chatbotAppointmentQuick');
  String get chatbotFAQTitle => translate('chatbotFAQTitle');
  String get chatbotFAQ1Question => translate('chatbotFAQ1Question');
  String get chatbotFAQ1Answer => translate('chatbotFAQ1Answer');
  String get chatbotFAQ2Question => translate('chatbotFAQ2Question');
  String get chatbotFAQ2Answer => translate('chatbotFAQ2Answer');
  String get chatbotFAQ3Question => translate('chatbotFAQ3Question');
  String get chatbotFAQ3Answer => translate('chatbotFAQ3Answer');
  String get chatbotFAQ4Question => translate('chatbotFAQ4Question');
  String get chatbotFAQ4Answer => translate('chatbotFAQ4Answer');
  String get chatbotFAQ5Question => translate('chatbotFAQ5Question');
  String get chatbotFAQ5Answer => translate('chatbotFAQ5Answer');
  String get chatbotInputHint => translate('chatbotInputHint');
  
  // Login & Registration
  String get alreadyRegisteredLogin => translate('alreadyRegisteredLogin');
  String get continueWithoutLogin => translate('continueWithoutLogin');
  String get alreadyRegistered => translate('alreadyRegistered');
  String get loginToAccess => translate('loginToAccess');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['it', 'en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

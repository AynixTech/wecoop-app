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
      'city': 'Città',
      'province': 'Provincia',
      'postalCode': 'CAP',
      'additionalInfo': 'Informazioni aggiuntive',
      'additionalInfoPlaceholder': 'Eventuali informazioni aggiuntive',
      'privacyConsent': 'Accetto il trattamento dei dati personali',
      'sendRequest': 'Invia Richiesta',
      'sending': 'Invio in corso...',
      'fillAllFields': 'Compila tutti i campi',
      'bookingConfirmed': 'Prenotazione confermata!',
      'connectionError': 'Errore di connessione',
      'selectDate': 'Seleziona una data',
      'availableSlots': 'Orari disponibili',
      'book': 'Prenora',
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
      'residencePermit': 'Permesso di Soggiorno',
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
      'operationCompleted': 'Operazione completata',
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
      'touristVisaRequest': 'Richiesta Visa per Turismo',
      'taxMediation': 'Mediazione Fiscale',
      'accountingSupport': 'Supporto Contabile',
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
    },
    'en': {
      'appTitle': 'WECOOP',
      'hello': 'Hello',
      'welcome': 'Welcome to WECOOP! Explore events, services and projects near you.',
      'user': 'User',
      'profile': 'Profile',
      'home': 'Home',
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
      'city': 'City',
      'province': 'Province',
      'postalCode': 'Postal Code',
      'additionalInfo': 'Additional information',
      'additionalInfoPlaceholder': 'Any additional information',
      'privacyConsent': 'I accept the processing of personal data',
      'sendRequest': 'Send Request',
      'sending': 'Sending...',
      'fillAllFields': 'Fill all fields',
      'bookingConfirmed': 'Booking confirmed!',
      'connectionError': 'Connection error',
      'selectDate': 'Select a date',
      'availableSlots': 'Available slots',
      'book': 'Book',
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
      'residencePermit': 'Residence Permit',
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
      'operationCompleted': 'Operation completed',
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
      'taxMediation': 'Tax Mediation',
      'accountingSupport': 'Accounting Support',
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
    },
    'es': {
      'appTitle': 'WECOOP',
      'hello': 'Hola',
      'welcome': '¡Bienvenida a WECOOP! Explora eventos, servicios y proyectos cerca de ti.',
      'user': 'Usuario',
      'profile': 'Perfil',
      'home': 'Inicio',
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
      'city': 'Ciudad',
      'province': 'Provincia',
      'postalCode': 'Código Postal',
      'additionalInfo': 'Información adicional',
      'additionalInfoPlaceholder': 'Cualquier información adicional',
      'privacyConsent': 'Acepto el tratamiento de datos personales',
      'sendRequest': 'Enviar Solicitud',
      'sending': 'Enviando...',
      'fillAllFields': 'Completa todos los campos',
      'bookingConfirmed': '¡Reserva confirmada!',
      'connectionError': 'Error de conexión',
      'selectDate': 'Selecciona una fecha',
      'availableSlots': 'Horarios disponibles',
      'book': 'Reservar',
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
      'residencePermit': 'Permiso de Residencia',
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
      'taxMediation': 'Mediación Fiscal',
      'accountingSupport': 'Soporte Contable',
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
  String get city => translate('city');
  String get province => translate('province');
  String get postalCode => translate('postalCode');
  String get additionalInfo => translate('additionalInfo');
  String get additionalInfoPlaceholder => translate('additionalInfoPlaceholder');
  String get privacyConsent => translate('privacyConsent');
  String get sendRequest => translate('sendRequest');
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

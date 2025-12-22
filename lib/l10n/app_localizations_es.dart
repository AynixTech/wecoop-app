// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'WECOOP';

  @override
  String get hello => 'Hola';

  @override
  String get welcome =>
      '¡Bienvenida a WECOOP! Explora eventos, servicios y proyectos cerca de ti.';

  @override
  String get user => 'Usuario';

  @override
  String get profile => 'Perfil';

  @override
  String get home => 'Inicio';

  @override
  String get calendar => 'Solicitudes';

  @override
  String get projects => 'Proyectos';

  @override
  String get services => 'Servicios';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirm => 'Sesión cerrada';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get rememberPassword => 'Recordar contraseña';

  @override
  String get loginButton => 'INICIAR SESIÓN';

  @override
  String get loginError => 'Error de inicio de sesión';

  @override
  String get networkError => 'Error de red';

  @override
  String get emailNotAvailable => 'correo no disponible';

  @override
  String get memberCard => 'Tarjeta de Socio WECOOP';

  @override
  String get cardNumber => 'N° Tarjeta';

  @override
  String get cardNotAvailable => 'Tarjeta no disponible';

  @override
  String get openDigitalCard => 'Abrir tarjeta digital';

  @override
  String get preferences => 'Preferencias';

  @override
  String get language => 'Idioma';

  @override
  String get areaOfInterest => 'Área de interés';

  @override
  String get participationHistory => 'Historial de participación';

  @override
  String get italian => 'Italiano';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get arabic => 'Árabe';

  @override
  String get culture => 'Cultura';

  @override
  String get sport => 'Deporte';

  @override
  String get training => 'Formación';

  @override
  String get volunteering => 'Voluntariado';

  @override
  String get socialServices => 'Servicios sociales';

  @override
  String get servicesTitle => '🛠️ Servicios';

  @override
  String get welcomeService => 'Acogida';

  @override
  String get taxMediationService => 'Mediación fiscal';

  @override
  String get accountingService => 'Soporte contable';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get upcomingEvents => '📅 Próximos eventos';

  @override
  String get activeProjects => '🤝 Proyectos activos';

  @override
  String get latestNews => '📰 Últimas noticias';

  @override
  String get quickAccess => '⚡ Acceso rápido';

  @override
  String get eventInterculturalDinner => 'Cena Intercultural';

  @override
  String get eventSewingLab => 'Taller de costura';

  @override
  String get eventItalianCourse => 'Curso de italiano';

  @override
  String get projectMafalda => 'MAFALDA';

  @override
  String get projectMafaldaDesc => 'Jóvenes e inclusión';

  @override
  String get projectWomentor => 'WOMENTOR';

  @override
  String get projectWomentorDesc => 'Mentoría entre mujeres';

  @override
  String get projectSportunity => 'SPORTUNITY';

  @override
  String get projectSportunityDesc => 'Deporte y comunidad';

  @override
  String get loading => 'Cargando...';

  @override
  String get noNews => 'No hay noticias disponibles';

  @override
  String get refresh => 'Actualizar';

  @override
  String get myRequests => 'Mis Solicitudes';

  @override
  String get allRequests => 'Todas';

  @override
  String get pendingPayment => 'Pendiente de pago';

  @override
  String get processing => 'En proceso';

  @override
  String get completed => 'Completadas';

  @override
  String get cancelled => 'Canceladas';

  @override
  String get requestDetails => 'Detalle de Solicitud';

  @override
  String get service => 'Servicio';

  @override
  String get description => 'Descripción';

  @override
  String get requestDate => 'Fecha de Solicitud';

  @override
  String get status => 'Estado';

  @override
  String get paymentInfo => 'Información de Pago';

  @override
  String get paymentStatus => 'Estado del Pago';

  @override
  String get paid => 'Pagado';

  @override
  String get notPaid => 'No pagado';

  @override
  String get paymentMethod => 'Método';

  @override
  String get paymentDate => 'Fecha de Pago';

  @override
  String get transactionId => 'ID de Transacción';

  @override
  String get amount => 'Importe';

  @override
  String get payNow => 'Pagar ahora';

  @override
  String get cannotOpenPaymentLink => 'No se puede abrir el enlace de pago';

  @override
  String get noRequestsForDay => 'No hay solicitudes para este día';

  @override
  String get noRequests => 'No se encontraron solicitudes';

  @override
  String get close => 'Cerrar';

  @override
  String get loginToAccessServices =>
      'Inicia sesión para acceder a todos los servicios reservados para socios.';

  @override
  String get membershipPendingApproval =>
      'Tu solicitud de membresía está pendiente de aprobación.';

  @override
  String get confirmationWithin24to48Hours =>
      'Recibirás una confirmación por email dentro de 24-48 horas.';

  @override
  String get onceApprovedAccessAllServices =>
      'Una vez aprobada, podrás acceder a todos los servicios.';

  @override
  String toAccessServicesBecomeMember(Object serviceName) {
    return 'Para acceder a los servicios de $serviceName debes ser socio de WECOOP.';
  }

  @override
  String get becomeMemberToAccess => 'Hazte socio para acceder a:';

  @override
  String get whyBecomeMember => '¿Por qué hacerse socio?';

  @override
  String get operationCompleted => 'Operación completada';

  @override
  String get fiscalCodeMustBe16Chars =>
      'El código fiscal debe tener 16 caracteres';

  @override
  String get birthPlace => 'Lugar de Nacimiento';

  @override
  String get invalidPostalCode => 'Código postal no válido';

  @override
  String get invalidEmail => 'Email no válido';

  @override
  String get fillFollowingFields => 'Completa los siguientes campos';

  @override
  String get sendingError => 'Error durante el envío';

  @override
  String get politicalAsylum => 'Asilo Político';

  @override
  String get internationalProtectionRequest =>
      'La solicitud de protección internacional es un proceso delicado. Te ayudaremos a preparar la documentación.';

  @override
  String get internationalProtection => 'Protección Internacional';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get countryOfOrigin => 'País de origen';

  @override
  String get dateOfArrivalInItaly => 'Fecha de llegada a Italia';

  @override
  String get reasonForRequest => 'Motivo de la solicitud';

  @override
  String get politicalPersecution => 'Persecución política';

  @override
  String get religiousPersecution => 'Persecución religiosa';

  @override
  String get persecutionSexualOrientation =>
      'Persecución por orientación sexual';

  @override
  String get war => 'Guerra';

  @override
  String get other => 'Otro';

  @override
  String get situationDescription => 'Descripción de la situación';

  @override
  String get hasFamilyInItaly => '¿Tienes familia en Italia?';

  @override
  String get additionalNotes => 'Notas adicionales';

  @override
  String get startRequest => 'Iniciar solicitud';

  @override
  String get touristVisaRequest => 'Solicitud de Visa Turística';

  @override
  String get taxMediation => 'Mediación Fiscal';

  @override
  String get accountingSupport => 'Soporte Contable';

  @override
  String get residencePermit => 'Permiso de Residencia';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get selectFiscalService => 'Selecciona el servicio fiscal';

  @override
  String get tax730Declaration => '730 - Declaración de la Renta';

  @override
  String get tax730Description =>
      'Preparación del modelo 730 para empleados y pensionistas';

  @override
  String get individualPerson => 'Persona Física';

  @override
  String get individualPersonDescription =>
      'Declaración de la renta para personas físicas';

  @override
  String get taxpayerType => 'Tipo de contribuyente';

  @override
  String get employee => 'Trabajador empleado';

  @override
  String get pensioner => 'Pensionista';

  @override
  String get fiscalYear => 'Año fiscal';

  @override
  String get hasDeductibleExpenses => '¿Tienes gastos deducibles?';

  @override
  String get notesAndAdditionalInfo => 'Notas e información adicional';

  @override
  String get incomeType => 'Tipo de ingresos';

  @override
  String get employedWork => 'Trabajo empleado';

  @override
  String get selfEmployed => 'Autónomo';

  @override
  String get pension => 'Pensión';

  @override
  String get capitalIncome => 'Ingresos de capital';

  @override
  String get otherIncome => 'Otros ingresos';

  @override
  String get multipleTypes => 'Múltiples tipos';

  @override
  String get hasProperties => '¿Tienes propiedades?';

  @override
  String get detailsAndNotes => 'Detalles y notas';
}

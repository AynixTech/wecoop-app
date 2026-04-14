import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wecoop_app/models/offerta_lavoro_model.dart';
import 'package:wecoop_app/screens/servizi/lavoro_orientamento_screen.dart';
import 'package:wecoop_app/services/offerte_lavoro_service.dart';
import 'package:wecoop_app/services/annunci_submission_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';

class _OfferteLavoroText {
  static const Map<String, Map<String, String>> _values = {
    'it': {
      'cannotOpenWhatsapp': 'Impossibile aprire WhatsApp',
      'supportTitle': 'Vuoi cercare lavoro?',
      'supportDescription':
          'Sfoglia le offerte disponibili in questa schermata oppure contatta WECOOP se vuoi supporto per orientamento, candidatura o attivazione dei servizi dedicati.',
      'refreshOffers': 'Aggiorna offerte',
      'openOrientation': 'Apri orientamento lavoro',
      'contactWecoopWhatsapp': 'Contatta WECOOP su WhatsApp',
      'supportWhatsappMessage':
          'Ciao WECOOP, vorrei informazioni per cercare lavoro o attivare servizi dedicati.',
      'screenTitle': 'Offerte e Annunci Lavoro',
      'announcements': 'Annunci',
      'seek': 'Cerco',
      'offer': 'Offro',
      'offersInfoTooltip': 'Info offerte',
      'orientationTooltip': 'Servizio orientamento',
      'seekServiceTitle': 'Cerco un servizio',
      'seekServiceSubtitle':
          'Pubblica una richiesta: ad esempio cerco babysitter, colf o aiuto anziani.',
      'offerServiceTitle': 'Offro un servizio',
      'offerServiceSubtitle':
          'Pubblica la tua disponibilita professionale: ad esempio offro servizio di babysitter.',
      'sendServiceRequest': 'Invia richiesta servizio',
      'sendServiceOffer': 'Invia offerta servizio',
      'filtersTitle': 'Filtri annunci',
      'searchHint': 'Cerca: baby sitter, badante, colf, OSS...',
      'scopes': 'Ambiti',
      'all': 'Tutti',
      'allFeminine': 'Tutte',
      'macroCategories': 'Macrocategorie',
      'macroCategory': 'Macrocategoria',
      'subCategories': 'Sottocategorie',
      'clearFilters': 'Pulisci filtri',
      'apply': 'Applica',
      'retry': 'Riprova',
      'activeFilters': 'Filtri (attivi)',
      'openFilters': 'Apri filtri',
      'emptyFiltered':
          'Nessun annuncio disponibile con questi filtri. Prova categorie come Pulizie/Limpieza, Badante o Baby sitter.',
      'featured': 'In evidenza',
      'attachedCv': 'CV allegato',
      'loadMore': 'Carica altri annunci',
      'detailUnavailable': 'Dettaglio non disponibile',
      'applicationSent': 'Candidatura inviata',
      'applicationError': 'Errore candidatura',
      'selectMacroCategory': 'Seleziona una macrocategoria',
      'selectSubCategory': 'Seleziona una sottocategoria',
      'acceptPrivacy': 'Devi accettare il consenso privacy',
      'selectValidSubCategory': 'Seleziona una sottocategoria valida',
      'invalidSubCategoryAfterAi':
          'Sottocategoria non valida dopo il controllo AI',
      'imageEncodingError': 'Errore nella codifica immagine: {error}',
      'imageLoadingError': 'Errore nel caricamento immagine: {error}',
      'announcementSentSuccess': 'Annuncio inviato con successo!',
      'sendError': 'Errore nell\'invio',
      'aiCategoryCheck': 'Controllo AI categoria',
      'aiCategoryCheckMessage':
          'La categoria selezionata sembra non coerente con la descrizione.\n\nSelezione attuale:\n• Macrocategoria: {currentMacro}\n• Sottocategoria: {currentCategory}\n\nSuggerimento AI:\n• Macrocategoria: {suggestedMacro}\n• Sottocategoria: {suggestedCategory}{reasonBlock}',
      'reasonLabel': 'Motivo: {reason}',
      'cancel': 'Annulla',
      'sendAnyway': 'Invia comunque',
      'applySuggestion': 'Applica suggerimento',
      'aiSuggestionNotApplicable':
          'Suggerimento AI non applicabile alle categorie disponibili',
      'aiCategoryApplied': 'Categoria AI applicata',
      'min12BaseDescription':
          'Inserisci almeno 12 caratteri nella descrizione base',
      'aiDescriptionUnavailable': 'Nessuna descrizione AI disponibile',
      'improveDescriptionUnavailable': 'Impossibile migliorare la descrizione',
      'min12Description': 'Inserisci almeno 12 caratteri nella descrizione',
      'suggestionUnavailable': 'Suggerimento non disponibile',
      'noUsefulSuggestion': 'Nessun suggerimento utile trovato',
      'aiDescriptionGenerated':
          'Descrizione AI generata. Puoi modificarla prima di inviare.',
      'aiDescriptionGeneratedWithSource':
          'Descrizione AI generata ({source}). Puoi modificarla prima di inviare.',
      'loadMyAnnouncementsError': 'Impossibile caricare i tuoi annunci',
      'applyAiSuggestionQuestion': 'Applicare suggerimento AI?',
      'setSelectionQuestion':
          'Vuoi impostare questa selezione?\nMacrocategoria: {macro}\nSottocategoria: {category}',
      'no': 'No',
      'yesApply': 'Si, applica',
      'suggestionNotApplied': 'Suggerimento non applicato',
      'suggestionWithReason': 'Suggerimento {source}: {reason}',
      'suggestedCategoryApplied': 'Categoria suggerita applicata',
      'mySeekAnnouncements': 'Le mie richieste (Cerco)',
      'myOfferAnnouncements': 'Le mie offerte (Offro)',
      'noAnnouncementsToShow': 'Non hai ancora annunci da mostrare.',
      'announcementFallback': 'Annuncio #{id}',
      'withoutCity': 'Senza citta',
      'deleteAnnouncementTooltip': 'Elimina annuncio',
      'deleteAnnouncementTitle': 'Eliminare annuncio?',
      'deleteAnnouncementMessage':
          'Questa azione spostera l\'annuncio nel cestino.',
      'delete': 'Elimina',
      'announcementDeleted': 'Annuncio eliminato',
      'deleteError': 'Errore eliminazione',
      'profileCompleteVerified':
          'Il tuo profilo e completo: i tuoi annunci mostreranno la coccarda Profilo verificato.',
      'profileIncompleteVerified':
          'Completa il profilo se vuoi mostrare la coccarda Profilo verificato nei tuoi annunci.',
      'myAnnouncements': 'I miei annunci',
      'announcementTitle': 'Titolo annuncio',
      'city': 'Citta',
      'contactLabel': 'Telefono o email di contatto',
      'description': 'Descrizione',
      'descriptionHint':
          'Descrivi mansione/servizio, orari e requisiti principali',
      'requiredField': 'Campo obbligatorio',
      'min20Chars': 'Inserisci almeno 20 caratteri',
      'aiImproveRunning': 'Miglioramento AI in corso...',
      'improveWithAi': 'Migliora descrizione con AI',
      'aiDescriptionEditable': 'Descrizione AI (modificabile)',
      'aiDescriptionHint':
          'La descrizione migliorata comparira qui. Puoi modificarla prima di inviare.',
      'aiSuggestionRunning': 'Suggerimento AI in corso...',
      'suggestCategoryWithAi': 'Suggerisci categoria con AI',
      'imageOptional': 'Immagine o foto (Opzionale)',
      'change': 'Cambia',
      'remove': 'Rimuovi',
      'selectImage': 'Seleziona immagine',
      'attachGeneratedCv': 'Allega un CV generato',
      'refreshCv': 'Aggiorna CV',
      'attachGeneratedCvHint':
          'Se stai cercando lavoro puoi associare uno dei tuoi CV generati. Chi apre l\'annuncio potra consultarlo.',
      'noGeneratedCv':
          'Nessun CV generato disponibile. Crea prima un CV nella sezione CV AI.',
      'attachCvOptional': 'CV da allegare (opzionale)',
      'noCvAttached': 'Nessun CV allegato',
      'pdfPreview': 'Anteprima PDF',
      'openWord': 'Apri Word',
      'privacyConsent': 'Accetto il trattamento dei dati personali',
      'sending': 'Invio in corso...',
      'insertAnnouncement': 'Inserisci annuncio',
      'insertAnnouncementDescription':
          'Compila i dati e invia la richiesta a WECOOP per la pubblicazione.',
      'sendAnnouncement': 'Invia annuncio',
      'verifiedProfile': 'Profilo verificato',
      'detailAnnouncement': 'Dettaglio annuncio',
      'schedule': 'Orari',
      'salary': 'Retribuzione',
      'deadline': 'Scadenza',
      'categories': 'Categorie',
      'attachedResume': 'Curriculum allegato',
      'attachedCvByAuthor': 'CV allegato dall\'autore dell\'annuncio',
      'viewCv': 'Vedi CV',
      'phone': 'Telefono',
      'call': 'Chiama',
      'contactWhatsapp': 'Contatta su WhatsApp',
      'openOriginalAnnouncement': 'Apri annuncio originale',
      'quickApplication': 'Candidatura rapida',
      'fullName': 'Nome e cognome',
      'phoneWhatsapp': 'Telefono / WhatsApp',
      'emailOptional': 'Email (opzionale)',
      'cityOptional': 'Citta (opzionale)',
      'noteOptional': 'Nota (opzionale)',
      'sendApplication': 'Invia candidatura',
      'selectMacroToSeeSubcategories':
          'Seleziona una macrocategoria per vedere le sottocategorie allineate.',
    },
    'en': {
      'cannotOpenWhatsapp': 'Unable to open WhatsApp',
      'supportTitle': 'Do you want to look for a job?',
      'supportDescription':
          'Browse the available opportunities on this screen or contact WECOOP if you want support for guidance, applications, or activation of dedicated services.',
      'refreshOffers': 'Refresh offers',
      'openOrientation': 'Open job guidance',
      'contactWecoopWhatsapp': 'Contact WECOOP on WhatsApp',
      'supportWhatsappMessage':
          'Hello WECOOP, I would like information about looking for a job or activating dedicated services.',
      'screenTitle': 'Job Offers and Announcements',
      'announcements': 'Announcements',
      'seek': 'Seeking',
      'offer': 'Offering',
      'offersInfoTooltip': 'Offers info',
      'orientationTooltip': 'Guidance service',
      'seekServiceTitle': 'I am looking for a service',
      'seekServiceSubtitle':
          'Publish a request: for example, I am looking for a babysitter, housekeeper, or elderly care support.',
      'offerServiceTitle': 'I offer a service',
      'offerServiceSubtitle':
          'Publish your professional availability: for example, I offer babysitting services.',
      'sendServiceRequest': 'Send service request',
      'sendServiceOffer': 'Send service offer',
      'filtersTitle': 'Announcement filters',
      'searchHint':
          'Search: babysitter, caregiver, housekeeper, health assistant...',
      'scopes': 'Scopes',
      'all': 'All',
      'allFeminine': 'All',
      'macroCategories': 'Macro categories',
      'macroCategory': 'Macro category',
      'subCategories': 'Subcategories',
      'clearFilters': 'Clear filters',
      'apply': 'Apply',
      'retry': 'Retry',
      'activeFilters': 'Filters (active)',
      'openFilters': 'Open filters',
      'emptyFiltered':
          'No announcements available with these filters. Try categories such as Cleaning, Caregiver, or Babysitter.',
      'featured': 'Featured',
      'attachedCv': 'CV attached',
      'loadMore': 'Load more announcements',
      'detailUnavailable': 'Details not available',
      'applicationSent': 'Application sent',
      'applicationError': 'Application error',
      'selectMacroCategory': 'Select a macro category',
      'selectSubCategory': 'Select a subcategory',
      'acceptPrivacy': 'You must accept the privacy consent',
      'selectValidSubCategory': 'Select a valid subcategory',
      'invalidSubCategoryAfterAi': 'Invalid subcategory after AI check',
      'imageEncodingError': 'Image encoding error: {error}',
      'imageLoadingError': 'Image loading error: {error}',
      'announcementSentSuccess': 'Announcement sent successfully!',
      'sendError': 'Sending error',
      'aiCategoryCheck': 'AI category check',
      'aiCategoryCheckMessage':
          'The selected category does not seem consistent with the description.\n\nCurrent selection:\n• Macro category: {currentMacro}\n• Subcategory: {currentCategory}\n\nAI suggestion:\n• Macro category: {suggestedMacro}\n• Subcategory: {suggestedCategory}{reasonBlock}',
      'reasonLabel': 'Reason: {reason}',
      'cancel': 'Cancel',
      'sendAnyway': 'Send anyway',
      'applySuggestion': 'Apply suggestion',
      'aiSuggestionNotApplicable':
          'AI suggestion cannot be applied to available categories',
      'aiCategoryApplied': 'AI category applied',
      'min12BaseDescription':
          'Enter at least 12 characters in the base description',
      'aiDescriptionUnavailable': 'No AI description available',
      'improveDescriptionUnavailable': 'Unable to improve the description',
      'min12Description': 'Enter at least 12 characters in the description',
      'suggestionUnavailable': 'Suggestion not available',
      'noUsefulSuggestion': 'No useful suggestion found',
      'aiDescriptionGenerated':
          'AI description generated. You can edit it before sending.',
      'aiDescriptionGeneratedWithSource':
          'AI description generated ({source}). You can edit it before sending.',
      'loadMyAnnouncementsError': 'Unable to load your announcements',
      'applyAiSuggestionQuestion': 'Apply AI suggestion?',
      'setSelectionQuestion':
          'Do you want to set this selection?\nMacro category: {macro}\nSubcategory: {category}',
      'no': 'No',
      'yesApply': 'Yes, apply',
      'suggestionNotApplied': 'Suggestion not applied',
      'suggestionWithReason': 'Suggestion {source}: {reason}',
      'suggestedCategoryApplied': 'Suggested category applied',
      'mySeekAnnouncements': 'My requests (Seeking)',
      'myOfferAnnouncements': 'My offers (Offering)',
      'noAnnouncementsToShow': 'You do not have any announcements to show yet.',
      'announcementFallback': 'Announcement #{id}',
      'withoutCity': 'Without city',
      'deleteAnnouncementTooltip': 'Delete announcement',
      'deleteAnnouncementTitle': 'Delete announcement?',
      'deleteAnnouncementMessage':
          'This action will move the announcement to the trash.',
      'delete': 'Delete',
      'announcementDeleted': 'Announcement deleted',
      'deleteError': 'Delete error',
      'profileCompleteVerified':
          'Your profile is complete: your announcements will show the Verified profile badge.',
      'profileIncompleteVerified':
          'Complete your profile if you want to show the Verified profile badge on your announcements.',
      'myAnnouncements': 'My announcements',
      'announcementTitle': 'Announcement title',
      'city': 'City',
      'contactLabel': 'Contact phone or email',
      'description': 'Description',
      'descriptionHint':
          'Describe duties/service, schedule, and main requirements',
      'requiredField': 'Required field',
      'min20Chars': 'Enter at least 20 characters',
      'aiImproveRunning': 'AI improvement in progress...',
      'improveWithAi': 'Improve description with AI',
      'aiDescriptionEditable': 'AI description (editable)',
      'aiDescriptionHint':
          'The improved description will appear here. You can edit it before sending.',
      'aiSuggestionRunning': 'AI suggestion in progress...',
      'suggestCategoryWithAi': 'Suggest category with AI',
      'imageOptional': 'Image or photo (Optional)',
      'change': 'Change',
      'remove': 'Remove',
      'selectImage': 'Select image',
      'attachGeneratedCv': 'Attach a generated CV',
      'refreshCv': 'Refresh CV',
      'attachGeneratedCvHint':
          'If you are looking for a job, you can link one of your generated CVs. Anyone opening the announcement will be able to view it.',
      'noGeneratedCv':
          'No generated CV available. Create a CV first in the AI CV section.',
      'attachCvOptional': 'CV to attach (optional)',
      'noCvAttached': 'No CV attached',
      'pdfPreview': 'PDF preview',
      'openWord': 'Open Word',
      'privacyConsent': 'I accept the processing of personal data',
      'sending': 'Sending...',
      'insertAnnouncement': 'Insert announcement',
      'insertAnnouncementDescription':
          'Fill in the details and send the request to WECOOP for publication.',
      'sendAnnouncement': 'Send announcement',
      'verifiedProfile': 'Verified profile',
      'detailAnnouncement': 'Announcement details',
      'schedule': 'Schedule',
      'salary': 'Salary',
      'deadline': 'Deadline',
      'categories': 'Categories',
      'attachedResume': 'Attached resume',
      'attachedCvByAuthor': 'CV attached by the author of the announcement',
      'viewCv': 'View CV',
      'phone': 'Phone',
      'call': 'Call',
      'contactWhatsapp': 'Contact on WhatsApp',
      'openOriginalAnnouncement': 'Open original announcement',
      'quickApplication': 'Quick application',
      'fullName': 'Full name',
      'phoneWhatsapp': 'Phone / WhatsApp',
      'emailOptional': 'Email (optional)',
      'cityOptional': 'City (optional)',
      'noteOptional': 'Note (optional)',
      'sendApplication': 'Send application',
      'selectMacroToSeeSubcategories':
          'Select a macro category to see the aligned subcategories.',
    },
    'es': {
      'cannotOpenWhatsapp': 'No se puede abrir WhatsApp',
      'supportTitle': '¿Quieres buscar trabajo?',
      'supportDescription':
          'Explora las ofertas disponibles en esta pantalla o contacta a WECOOP si quieres apoyo para orientación, candidatura o activación de servicios dedicados.',
      'refreshOffers': 'Actualizar ofertas',
      'openOrientation': 'Abrir orientación laboral',
      'contactWecoopWhatsapp': 'Contactar a WECOOP por WhatsApp',
      'supportWhatsappMessage':
          'Hola WECOOP, quisiera información para buscar trabajo o activar servicios dedicados.',
      'screenTitle': 'Ofertas y Anuncios de Trabajo',
      'announcements': 'Anuncios',
      'seek': 'Busco',
      'offer': 'Ofrezco',
      'offersInfoTooltip': 'Información de ofertas',
      'orientationTooltip': 'Servicio de orientación',
      'seekServiceTitle': 'Busco un servicio',
      'seekServiceSubtitle':
          'Publica una solicitud: por ejemplo busco niñera, empleada doméstica o ayuda para personas mayores.',
      'offerServiceTitle': 'Ofrezco un servicio',
      'offerServiceSubtitle':
          'Publica tu disponibilidad profesional: por ejemplo ofrezco servicio de niñera.',
      'sendServiceRequest': 'Enviar solicitud de servicio',
      'sendServiceOffer': 'Enviar oferta de servicio',
      'filtersTitle': 'Filtros de anuncios',
      'searchHint':
          'Buscar: niñera, cuidador, limpieza, asistente sociosanitario...',
      'scopes': 'Ámbitos',
      'all': 'Todos',
      'allFeminine': 'Todas',
      'macroCategories': 'Macrocategorías',
      'macroCategory': 'Macrocategoría',
      'subCategories': 'Subcategorías',
      'clearFilters': 'Limpiar filtros',
      'apply': 'Aplicar',
      'retry': 'Reintentar',
      'activeFilters': 'Filtros (activos)',
      'openFilters': 'Abrir filtros',
      'emptyFiltered':
          'No hay anuncios disponibles con estos filtros. Prueba categorías como Limpieza, Cuidador o Niñera.',
      'featured': 'Destacado',
      'attachedCv': 'CV adjunto',
      'loadMore': 'Cargar más anuncios',
      'detailUnavailable': 'Detalle no disponible',
      'applicationSent': 'Candidatura enviada',
      'applicationError': 'Error en la candidatura',
      'selectMacroCategory': 'Selecciona una macrocategoría',
      'selectSubCategory': 'Selecciona una subcategoría',
      'acceptPrivacy': 'Debes aceptar el consentimiento de privacidad',
      'selectValidSubCategory': 'Selecciona una subcategoría válida',
      'invalidSubCategoryAfterAi':
          'Subcategoría no válida después del control de IA',
      'imageEncodingError': 'Error al codificar la imagen: {error}',
      'imageLoadingError': 'Error al cargar la imagen: {error}',
      'announcementSentSuccess': '¡Anuncio enviado con éxito!',
      'sendError': 'Error al enviar',
      'aiCategoryCheck': 'Control de categoría con IA',
      'aiCategoryCheckMessage':
          'La categoría seleccionada no parece coherente con la descripción.\n\nSelección actual:\n• Macrocategoría: {currentMacro}\n• Subcategoría: {currentCategory}\n\nSugerencia de IA:\n• Macrocategoría: {suggestedMacro}\n• Subcategoría: {suggestedCategory}{reasonBlock}',
      'reasonLabel': 'Motivo: {reason}',
      'cancel': 'Cancelar',
      'sendAnyway': 'Enviar de todos modos',
      'applySuggestion': 'Aplicar sugerencia',
      'aiSuggestionNotApplicable':
          'La sugerencia de IA no se puede aplicar a las categorías disponibles',
      'aiCategoryApplied': 'Categoría de IA aplicada',
      'min12BaseDescription':
          'Ingresa al menos 12 caracteres en la descripción base',
      'aiDescriptionUnavailable': 'No hay descripción IA disponible',
      'improveDescriptionUnavailable': 'No se puede mejorar la descripción',
      'min12Description': 'Ingresa al menos 12 caracteres en la descripción',
      'suggestionUnavailable': 'Sugerencia no disponible',
      'noUsefulSuggestion': 'No se encontró una sugerencia útil',
      'aiDescriptionGenerated':
          'Descripción IA generada. Puedes modificarla antes de enviarla.',
      'aiDescriptionGeneratedWithSource':
          'Descripción IA generada ({source}). Puedes modificarla antes de enviarla.',
      'loadMyAnnouncementsError': 'No se pueden cargar tus anuncios',
      'applyAiSuggestionQuestion': '¿Aplicar sugerencia de IA?',
      'setSelectionQuestion':
          '¿Quieres establecer esta selección?\nMacrocategoría: {macro}\nSubcategoría: {category}',
      'no': 'No',
      'yesApply': 'Sí, aplicar',
      'suggestionNotApplied': 'Sugerencia no aplicada',
      'suggestionWithReason': 'Sugerencia {source}: {reason}',
      'suggestedCategoryApplied': 'Categoría sugerida aplicada',
      'mySeekAnnouncements': 'Mis solicitudes (Busco)',
      'myOfferAnnouncements': 'Mis ofertas (Ofrezco)',
      'noAnnouncementsToShow': 'Todavía no tienes anuncios para mostrar.',
      'announcementFallback': 'Anuncio #{id}',
      'withoutCity': 'Sin ciudad',
      'deleteAnnouncementTooltip': 'Eliminar anuncio',
      'deleteAnnouncementTitle': '¿Eliminar anuncio?',
      'deleteAnnouncementMessage':
          'Esta acción moverá el anuncio a la papelera.',
      'delete': 'Eliminar',
      'announcementDeleted': 'Anuncio eliminado',
      'deleteError': 'Error al eliminar',
      'profileCompleteVerified':
          'Tu perfil está completo: tus anuncios mostrarán la insignia Perfil verificado.',
      'profileIncompleteVerified':
          'Completa el perfil si quieres mostrar la insignia Perfil verificado en tus anuncios.',
      'myAnnouncements': 'Mis anuncios',
      'announcementTitle': 'Título del anuncio',
      'city': 'Ciudad',
      'contactLabel': 'Teléfono o email de contacto',
      'description': 'Descripción',
      'descriptionHint':
          'Describe tarea/servicio, horarios y requisitos principales',
      'requiredField': 'Campo obligatorio',
      'min20Chars': 'Ingresa al menos 20 caracteres',
      'aiImproveRunning': 'Mejora con IA en curso...',
      'improveWithAi': 'Mejorar descripción con IA',
      'aiDescriptionEditable': 'Descripción IA (editable)',
      'aiDescriptionHint':
          'La descripción mejorada aparecerá aquí. Puedes modificarla antes de enviarla.',
      'aiSuggestionRunning': 'Sugerencia IA en curso...',
      'suggestCategoryWithAi': 'Sugerir categoría con IA',
      'imageOptional': 'Imagen o foto (Opcional)',
      'change': 'Cambiar',
      'remove': 'Quitar',
      'selectImage': 'Seleccionar imagen',
      'attachGeneratedCv': 'Adjuntar un CV generado',
      'refreshCv': 'Actualizar CV',
      'attachGeneratedCvHint':
          'Si estás buscando trabajo, puedes asociar uno de tus CV generados. Quien abra el anuncio podrá consultarlo.',
      'noGeneratedCv':
          'No hay ningún CV generado disponible. Crea primero un CV en la sección CV IA.',
      'attachCvOptional': 'CV para adjuntar (opcional)',
      'noCvAttached': 'Ningún CV adjunto',
      'pdfPreview': 'Vista previa PDF',
      'openWord': 'Abrir Word',
      'privacyConsent': 'Acepto el tratamiento de los datos personales',
      'sending': 'Envío en curso...',
      'insertAnnouncement': 'Insertar anuncio',
      'insertAnnouncementDescription':
          'Completa los datos y envía la solicitud a WECOOP para la publicación.',
      'sendAnnouncement': 'Enviar anuncio',
      'verifiedProfile': 'Perfil verificado',
      'detailAnnouncement': 'Detalle del anuncio',
      'schedule': 'Horario',
      'salary': 'Retribución',
      'deadline': 'Vencimiento',
      'categories': 'Categorías',
      'attachedResume': 'Currículum adjunto',
      'attachedCvByAuthor': 'CV adjunto por el autor del anuncio',
      'viewCv': 'Ver CV',
      'phone': 'Teléfono',
      'call': 'Llamar',
      'contactWhatsapp': 'Contactar por WhatsApp',
      'openOriginalAnnouncement': 'Abrir anuncio original',
      'quickApplication': 'Candidatura rápida',
      'fullName': 'Nombre y apellidos',
      'phoneWhatsapp': 'Teléfono / WhatsApp',
      'emailOptional': 'Email (opcional)',
      'cityOptional': 'Ciudad (opcional)',
      'noteOptional': 'Nota (opcional)',
      'sendApplication': 'Enviar candidatura',
      'selectMacroToSeeSubcategories':
          'Selecciona una macrocategoría para ver las subcategorías alineadas.',
    },
  };

  static String tr(
    BuildContext context,
    String key, {
    Map<String, String>? params,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    var text = _values[code]?[key] ?? _values['it']?[key] ?? key;
    if (params != null) {
      for (final entry in params.entries) {
        text = text.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return text;
  }
}

class _CategoriaMenuHelper {
  static const Map<String, List<String>> macroKeywordMap = {
    'personal-care': [
      'badante',
      'baby',
      'bambin',
      'colf',
      'puliz',
      'domestic',
      'caregiver',
      'assistenza',
    ],
    'health-wellbeing': [
      'oss',
      'aso',
      'sanit',
      'infermier',
      'fisioter',
      'wellness',
    ],
    'food-hospitality': [
      'bar',
      'ristor',
      'cucina',
      'chef',
      'camerier',
      'hotel',
      'hospitality',
    ],
    'events-creativity': [
      'dj',
      'evento',
      'music',
      'foto',
      'video',
      'grafica',
      'animaz',
    ],
    'construction-logistics': [
      'edil',
      'murator',
      'magazzin',
      'autist',
      'logistic',
      'trasport',
      'manutenz',
    ],
    'industry-manufacturing': [
      'operaio',
      'produzion',
      'fabbrica',
      'confezion',
      'assembl',
      'imball',
      'saldat',
      'metal',
    ],
    'agriculture-green': [
      'agricol',
      'raccolta',
      'campagn',
      'bracciante',
      'vivaio',
      'giardin',
      'verde',
    ],
    'retail-customer-service': [
      'commess',
      'cassier',
      'negozio',
      'vendit',
      'call center',
      'customer',
      'scaffal',
    ],
    'education-training': [
      'educat',
      'insegn',
      'docent',
      'ripetizion',
      'tutor',
      'formazion',
      'scuola',
    ],
    'admin-finance': [
      'amministr',
      'contabil',
      'segreter',
      'back office',
      'front office',
      'finanz',
      'paghe',
    ],
    'technology-digital': [
      'informat',
      'tecnolog',
      'digital',
      'software',
      'program',
      'svilupp',
      'developer',
      'web',
      'social media',
      'marketing digital',
      'grafic',
    ],
    'home-support-services': [
      'faccende',
      'stiro',
      'spesa',
      'accompagno',
      'custodia',
      'aiuto casa',
      'commission',
    ],
  };

  static const Map<String, Map<String, String>> macroLabels = {
    'personal-care': {
      'it': 'Cura persona',
      'en': 'Personal care',
      'es': 'Cuidado personal',
    },
    'health-wellbeing': {
      'it': 'Sanita e benessere',
      'en': 'Health and wellbeing',
      'es': 'Salud y bienestar',
    },
    'food-hospitality': {
      'it': 'Ristorazione e ospitalita',
      'en': 'Food and hospitality',
      'es': 'Hosteleria y restauracion',
    },
    'events-creativity': {
      'it': 'Eventi e creativita',
      'en': 'Events and creativity',
      'es': 'Eventos y creatividad',
    },
    'construction-logistics': {
      'it': 'Edilizia e logistica',
      'en': 'Construction and logistics',
      'es': 'Construccion y logistica',
    },
    'industry-manufacturing': {
      'it': 'Industria e produzione',
      'en': 'Industry and manufacturing',
      'es': 'Industria y produccion',
    },
    'agriculture-green': {
      'it': 'Agricoltura e verde',
      'en': 'Agriculture and green jobs',
      'es': 'Agricultura y areas verdes',
    },
    'retail-customer-service': {
      'it': 'Commercio e assistenza clienti',
      'en': 'Retail and customer service',
      'es': 'Comercio y atencion al cliente',
    },
    'education-training': {
      'it': 'Educazione e formazione',
      'en': 'Education and training',
      'es': 'Educacion y formacion',
    },
    'admin-finance': {
      'it': 'Amministrazione e finanza',
      'en': 'Administration and finance',
      'es': 'Administracion y finanzas',
    },
    'technology-digital': {
      'it': 'Tecnologia e digitale',
      'en': 'Technology and digital',
      'es': 'Tecnologia y digital',
    },
    'home-support-services': {
      'it': 'Servizi di supporto domestico',
      'en': 'Home support services',
      'es': 'Servicios de apoyo domestico',
    },
    'other': {'it': 'Altro', 'en': 'Other', 'es': 'Otros'},
  };

  static const Map<String, String> categoryValueBySlug = {
    'baby-sitter': 'babysitter',
    'badante': 'caregiver',
    'colf': 'housekeeper',
    'oss-osa': 'health-assistant',
    'aso': 'dental-assistant',
    'segreteria': 'office-assistant',
    'manicure': 'manicure',
    'dentista': 'dentistry',
    'massaggi': 'massage-wellness',
    'fotografo': 'photographer',
    'dj': 'dj-events',
    'animatori': 'entertainers',
    'pulizie-limpieza': 'cleaning',
    'lavapiatti': 'dishwasher',
    'aiuto-cucina': 'kitchen-assistant',
    'cameriere': 'waiter',
    'pizzaiolo': 'pizza-chef',
    'magazziniere': 'warehouse-worker',
    'rider-consegne': 'delivery-rider',
    'autista': 'driver',
    'operaio-generico': 'general-worker',
    'confezionamento': 'packaging-worker',
    'saldatore': 'welder',
    'agricoltura-bracciante': 'farm-worker',
    'raccolta-frutta': 'fruit-picker',
    'giardiniere': 'gardener',
    'elettricista': 'electrician',
    'idraulico': 'plumber',
    'imbianchino': 'painter',
    'portiere-sicurezza': 'security-doorman',
    'cucito-sartoria': 'tailor-seamstress',
    'parrucchiera-estetista': 'beauty-hairdresser',
    'call-center': 'call-center-operator',
    'commesso-cassa': 'shop-assistant-cashier',
    'scaffalista': 'shelf-stocker',
    'insegnante': 'teacher',
    'educatore': 'educator',
    'tutor-ripetizioni': 'tutor',
    'formatore': 'trainer',
    'impiegato-amministrativo': 'administrative-clerk',
    'contabile': 'accountant',
    'front-office-reception': 'receptionist',
    'back-office': 'back-office-clerk',
    'social-media-manager': 'social-media-manager',
    'sviluppatore-web': 'web-developer',
    'supporto-it': 'it-support-technician',
    'data-entry': 'data-entry-clerk',
    'stiro': 'ironing-service',
    'spesa-domicilio': 'grocery-assistant',
    'accompagnamento': 'accompaniment-service',
    'custodia-casa': 'home-caretaker',
  };

  static const Map<String, Map<String, String>> categoryLabels = {
    'babysitter': {'it': 'Baby sitter', 'en': 'Babysitter', 'es': 'Ninera'},
    'caregiver': {'it': 'Badante', 'en': 'Caregiver', 'es': 'Cuidador/a'},
    'housekeeper': {
      'it': 'Colf',
      'en': 'Housekeeper',
      'es': 'Empleada domestica',
    },
    'health-assistant': {
      'it': 'OSS / OSA',
      'en': 'Health assistant',
      'es': 'Asistente sociosanitario',
    },
    'dental-assistant': {
      'it': 'ASO',
      'en': 'Dental assistant',
      'es': 'Asistente dental',
    },
    'office-assistant': {
      'it': 'Segreteria',
      'en': 'Office assistant',
      'es': 'Asistente de oficina',
    },
    'manicure': {
      'it': 'Manicure / Onicotecnica',
      'en': 'Manicure / Nail technician',
      'es': 'Manicura / Tecnica de unas',
    },
    'dentistry': {
      'it': 'Dentista / Odontoiatria',
      'en': 'Dentistry',
      'es': 'Odontologia',
    },
    'massage-wellness': {
      'it': 'Massaggi / Benessere',
      'en': 'Massage / Wellness',
      'es': 'Masajes / Bienestar',
    },
    'photographer': {
      'it': 'Fotografo / Fotografa',
      'en': 'Photographer',
      'es': 'Fotografo/a',
    },
    'dj-events': {
      'it': 'DJ / Musica Eventi',
      'en': 'DJ / Event music',
      'es': 'DJ / Musica para eventos',
    },
    'entertainers': {
      'it': 'Animatori / Animatrici',
      'en': 'Entertainers',
      'es': 'Animadores/as',
    },
    'cleaning': {
      'it': 'Pulizie / Limpieza',
      'en': 'Cleaning',
      'es': 'Limpieza',
    },
    'dishwasher': {'it': 'Lavapiatti', 'en': 'Dishwasher', 'es': 'Lavaplatos'},
    'kitchen-assistant': {
      'it': 'Aiuto cucina',
      'en': 'Kitchen assistant',
      'es': 'Ayudante de cocina',
    },
    'waiter': {
      'it': 'Cameriere/a',
      'en': 'Waiter/Waitress',
      'es': 'Camarero/a',
    },
    'pizza-chef': {'it': 'Pizzaiolo/a', 'en': 'Pizza chef', 'es': 'Pizzero/a'},
    'warehouse-worker': {
      'it': 'Magazziniere',
      'en': 'Warehouse worker',
      'es': 'Mozo de almacen',
    },
    'delivery-rider': {
      'it': 'Rider / Consegne',
      'en': 'Delivery rider',
      'es': 'Repartidor/a',
    },
    'driver': {'it': 'Autista', 'en': 'Driver', 'es': 'Conductor/a'},
    'general-worker': {
      'it': 'Operaio generico',
      'en': 'General worker',
      'es': 'Operario general',
    },
    'packaging-worker': {
      'it': 'Confezionamento',
      'en': 'Packaging worker',
      'es': 'Operario de envasado',
    },
    'welder': {'it': 'Saldatore', 'en': 'Welder', 'es': 'Soldador/a'},
    'farm-worker': {
      'it': 'Bracciante agricolo',
      'en': 'Farm worker',
      'es': 'Jornalero agricola',
    },
    'fruit-picker': {
      'it': 'Raccolta frutta',
      'en': 'Fruit picker',
      'es': 'Recolector/a de fruta',
    },
    'gardener': {'it': 'Giardiniere', 'en': 'Gardener', 'es': 'Jardinero/a'},
    'electrician': {
      'it': 'Elettricista',
      'en': 'Electrician',
      'es': 'Electricista',
    },
    'plumber': {'it': 'Idraulico', 'en': 'Plumber', 'es': 'Fontanero/a'},
    'painter': {'it': 'Imbianchino', 'en': 'Painter', 'es': 'Pintor/a'},
    'security-doorman': {
      'it': 'Portiere / Sicurezza',
      'en': 'Doorman / Security',
      'es': 'Portero / Seguridad',
    },
    'tailor-seamstress': {
      'it': 'Cucito / Sartoria',
      'en': 'Tailor / Seamstress',
      'es': 'Costura / Sastreria',
    },
    'beauty-hairdresser': {
      'it': 'Parrucchiera / Estetista',
      'en': 'Hairdresser / Beautician',
      'es': 'Peluqueria / Estetica',
    },
    'call-center-operator': {
      'it': 'Operatore call center',
      'en': 'Call center operator',
      'es': 'Operador/a de call center',
    },
    'shop-assistant-cashier': {
      'it': 'Commesso/a / Cassa',
      'en': 'Shop assistant / Cashier',
      'es': 'Dependiente/a / Caja',
    },
    'shelf-stocker': {
      'it': 'Scaffalista',
      'en': 'Shelf stocker',
      'es': 'Repositor/a',
    },
    'teacher': {'it': 'Insegnante', 'en': 'Teacher', 'es': 'Profesor/a'},
    'educator': {
      'it': 'Educatore / Educatrice',
      'en': 'Educator',
      'es': 'Educador/a',
    },
    'tutor': {
      'it': 'Tutor / Ripetizioni',
      'en': 'Tutor / Private lessons',
      'es': 'Tutor / Clases particulares',
    },
    'trainer': {
      'it': 'Formatore / Formatrice',
      'en': 'Trainer',
      'es': 'Formador/a',
    },
    'administrative-clerk': {
      'it': 'Impiegato amministrativo',
      'en': 'Administrative clerk',
      'es': 'Administrativo/a',
    },
    'accountant': {'it': 'Contabile', 'en': 'Accountant', 'es': 'Contable'},
    'receptionist': {
      'it': 'Front office / Reception',
      'en': 'Front office / Reception',
      'es': 'Recepcion',
    },
    'back-office-clerk': {
      'it': 'Back office',
      'en': 'Back office clerk',
      'es': 'Back office',
    },
    'social-media-manager': {
      'it': 'Social media manager',
      'en': 'Social media manager',
      'es': 'Gestor/a de redes sociales',
    },
    'web-developer': {
      'it': 'Sviluppatore web',
      'en': 'Web developer',
      'es': 'Desarrollador/a web',
    },
    'it-support-technician': {
      'it': 'Tecnico supporto IT',
      'en': 'IT support technician',
      'es': 'Tecnico/a de soporte IT',
    },
    'data-entry-clerk': {
      'it': 'Data entry',
      'en': 'Data entry clerk',
      'es': 'Auxiliar de entrada de datos',
    },
    'ironing-service': {
      'it': 'Stiro',
      'en': 'Ironing service',
      'es': 'Servicio de planchado',
    },
    'grocery-assistant': {
      'it': 'Aiuto spesa',
      'en': 'Grocery assistant',
      'es': 'Ayuda para compras',
    },
    'accompaniment-service': {
      'it': 'Accompagnamento',
      'en': 'Accompaniment service',
      'es': 'Servicio de acompanamiento',
    },
    'home-caretaker': {
      'it': 'Custodia casa',
      'en': 'Home caretaker',
      'es': 'Cuidador/a de hogar',
    },
  };

  static const Map<String, String> categoryMacroByValue = {
    'teacher': 'education-training',
    'educator': 'education-training',
    'tutor': 'education-training',
    'trainer': 'education-training',
    'administrative-clerk': 'admin-finance',
    'accountant': 'admin-finance',
    'receptionist': 'admin-finance',
    'back-office-clerk': 'admin-finance',
    'office-assistant': 'admin-finance',
    'social-media-manager': 'technology-digital',
    'web-developer': 'technology-digital',
    'it-support-technician': 'technology-digital',
    'data-entry-clerk': 'technology-digital',
    'ironing-service': 'home-support-services',
    'grocery-assistant': 'home-support-services',
    'accompaniment-service': 'home-support-services',
    'home-caretaker': 'home-support-services',
  };

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[-_]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String resolveMacro(OffertaCategoria category) {
    final categoryValue = categoryValueFromSlug(category.slug);
    final mappedMacro = categoryMacroByValue[categoryValue];
    if (mappedMacro != null) {
      return mappedMacro;
    }

    final haystack =
        '${_normalize(category.name)} ${_normalize(category.slug)}';

    for (final entry in macroKeywordMap.entries) {
      for (final keyword in entry.value) {
        if (haystack.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'other';
  }

  static String macroLabel(String macroValue, String languageCode) {
    final labels = macroLabels[macroValue];
    if (labels == null) return macroValue;
    return labels[languageCode] ?? labels['it'] ?? macroValue;
  }

  static String categoryValueFromSlug(String slug) {
    final normalizedSlug = slug.toLowerCase().trim();
    return categoryValueBySlug[normalizedSlug] ?? normalizedSlug;
  }

  static String categoryLabel(OffertaCategoria category, String languageCode) {
    final value = categoryValueFromSlug(category.slug);
    final labels = categoryLabels[value];
    if (labels == null) return category.name;
    return labels[languageCode] ?? labels['it'] ?? category.name;
  }

  static bool _isOtherMacro(String macroValue) {
    return _normalize(macroValue) == 'other';
  }

  static bool _isOtherCategory(OffertaCategoria category) {
    final normalizedSlug = _normalize(category.slug);
    final normalizedValue = _normalize(categoryValueFromSlug(category.slug));
    final normalizedName = _normalize(category.name);

    return normalizedSlug == 'altro' ||
        normalizedSlug == 'other' ||
        normalizedSlug == 'otros' ||
        normalizedValue == 'other' ||
        normalizedName == 'altro' ||
        normalizedName == 'other' ||
        normalizedName == 'otros';
  }

  static List<String> sortMacroNames(
    Iterable<String> macros,
    String languageCode,
  ) {
    final list = macros.toList();
    list.sort((a, b) {
      final aIsOther = _isOtherMacro(a);
      final bIsOther = _isOtherMacro(b);
      if (aIsOther && !bIsOther) return 1;
      if (!aIsOther && bIsOther) return -1;

      final aLabel = _normalize(macroLabel(a, languageCode));
      final bLabel = _normalize(macroLabel(b, languageCode));
      return aLabel.compareTo(bLabel);
    });
    return list;
  }

  static List<OffertaCategoria> sortSubCategories(
    Iterable<OffertaCategoria> categories,
    String languageCode,
  ) {
    final list = categories.toList();
    list.sort((a, b) {
      final aIsOther = _isOtherCategory(a);
      final bIsOther = _isOtherCategory(b);
      if (aIsOther && !bIsOther) return 1;
      if (!aIsOther && bIsOther) return -1;

      final aLabel = _normalize(categoryLabel(a, languageCode));
      final bLabel = _normalize(categoryLabel(b, languageCode));
      return aLabel.compareTo(bLabel);
    });
    return list;
  }

  static OffertaCategoria? findCategoryByValue(
    Iterable<OffertaCategoria> categories,
    String? value,
  ) {
    if (value == null || value.isEmpty) return null;
    for (final category in categories) {
      if (categoryValueFromSlug(category.slug) == value) {
        return category;
      }
    }
    return null;
  }

  static Map<String, List<OffertaCategoria>> groupByMacro(
    List<OffertaCategoria> categories,
  ) {
    final map = <String, List<OffertaCategoria>>{};
    for (final category in categories) {
      final macro = resolveMacro(category);
      map.putIfAbsent(macro, () => <OffertaCategoria>[]).add(category);
    }

    final sortedKeys = map.keys.toList()..sort();
    final sortedMap = <String, List<OffertaCategoria>>{};
    for (final key in sortedKeys) {
      final items = map[key]!;
      items.sort((a, b) => a.name.compareTo(b.name));
      sortedMap[key] = items;
    }

    return sortedMap;
  }
}

class OfferteLavoroScreen extends StatefulWidget {
  const OfferteLavoroScreen({super.key});

  @override
  State<OfferteLavoroScreen> createState() => _OfferteLavoroScreenState();
}

class _CategoryExplorerSelector extends StatelessWidget {
  final Map<String, List<OffertaCategoria>> categoriesByMacro;
  final String languageCode;
  final String? selectedMacro;
  final String? selectedCategoryValue;
  final String macroLabel;
  final String subCategoryLabel;
  final String allMacroText;
  final String allSubCategoryText;
  final ValueChanged<String?> onMacroChanged;
  final ValueChanged<String?> onSubCategoryChanged;

  const _CategoryExplorerSelector({
    required this.categoriesByMacro,
    required this.languageCode,
    required this.selectedMacro,
    required this.selectedCategoryValue,
    required this.macroLabel,
    required this.subCategoryLabel,
    required this.allMacroText,
    required this.allSubCategoryText,
    required this.onMacroChanged,
    required this.onSubCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n =
        (String key, {Map<String, String>? params}) =>
            _OfferteLavoroText.tr(context, key, params: params);
    final macroNames = _CategoriaMenuHelper.sortMacroNames(
      categoriesByMacro.keys,
      languageCode,
    );

    final subCategories =
        selectedMacro == null
            ? const <OffertaCategoria>[]
            : (categoriesByMacro[selectedMacro] ?? const <OffertaCategoria>[]);

    final sortedSubCategories = _CategoriaMenuHelper.sortSubCategories(
      subCategories,
      languageCode,
    );

    Widget buildMacroRow(String? macroValue, String label) {
      final isSelected = selectedMacro == macroValue;
      return InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onMacroChanged(macroValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF7FF) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF5AA3E6)
                      : Colors.blueGrey.shade100,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected
                            ? const Color(0xFF1C4E80)
                            : const Color(0xFF22313F),
                  ),
                ),
              ),
              Icon(
                isSelected
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18,
                color: isSelected ? const Color(0xFF1C4E80) : Colors.blueGrey,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.shade100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(macroLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          buildMacroRow(null, allMacroText),
          const SizedBox(height: 8),
          ...macroNames.map((macro) {
            final isSelected = selectedMacro == macro;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildMacroRow(
                    macro,
                    _CategoriaMenuHelper.macroLabel(macro, languageCode),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD6E9FA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subCategoryLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Builder(
                                  builder: (context) {
                                    final isAllSelected =
                                        selectedCategoryValue == null;
                                    return ChoiceChip(
                                      selected: isAllSelected,
                                      selectedColor: const Color(0xFF1C4E80),
                                      checkmarkColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color:
                                            isAllSelected
                                                ? Colors.white
                                                : const Color(0xFF22313F),
                                        fontWeight:
                                            isAllSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                      ),
                                      label: Text(allSubCategoryText),
                                      onSelected:
                                          (_) => onSubCategoryChanged(null),
                                    );
                                  },
                                ),
                                ...sortedSubCategories.map((category) {
                                  final value =
                                      _CategoriaMenuHelper.categoryValueFromSlug(
                                        category.slug,
                                      );
                                  final isSelectedCategory =
                                      selectedCategoryValue == value;
                                  return ChoiceChip(
                                    selected: isSelectedCategory,
                                    selectedColor: const Color(0xFF1C4E80),
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          isSelectedCategory
                                              ? Colors.white
                                              : const Color(0xFF22313F),
                                      fontWeight:
                                          isSelectedCategory
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                    ),
                                    label: Text(
                                      _CategoriaMenuHelper.categoryLabel(
                                        category,
                                        languageCode,
                                      ),
                                    ),
                                    onSelected:
                                        (_) => onSubCategoryChanged(value),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (selectedMacro == null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n('selectMacroToSeeSubcategories'),
                style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _OfferteLavoroScreenState extends State<OfferteLavoroScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const String _wecoopWhatsAppNumber = '393515112113';
  static const Color _activeMenuColor = Color(0xFF1282A8);
  static const Color _inactiveMenuColor = Color(0xFF9CA3AF);

  final TextEditingController _searchController = TextEditingController();

  List<OffertaLavoro> _offerte = [];
  List<OffertaCategoria> _categorie = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String? _selectedCategoriaSlug;
  String? _selectedMacroCategoria;
  String? _selectedJobDirection;
  int _currentPage = 1;
  int _totalPages = 1;

  Map<String, List<OffertaCategoria>> get _categorieByMacro {
    return _CategoriaMenuHelper.groupByMacro(_categorie);
  }

  List<OffertaLavoro> get _offerteFiltrate {
    if (_selectedCategoriaSlug != null && _selectedCategoriaSlug!.isNotEmpty) {
      return _offerte
          .where((offerta) => _matchesSelectedSubCategory(offerta))
          .toList();
    }

    if (_selectedMacroCategoria == null || _selectedMacroCategoria!.isEmpty) {
      return _offerte;
    }

    return _offerte.where((offerta) {
      return _matchesSelectedMacro(offerta);
    }).toList();
  }

  bool _matchesSelectedMacro(OffertaLavoro offerta) {
    final selectedMacro = _selectedMacroCategoria;
    if (selectedMacro == null || selectedMacro.isEmpty) return true;

    final normalizedSelected = _CategoriaMenuHelper._normalize(selectedMacro);

    if (offerta.categoryMacro.isNotEmpty &&
        _CategoriaMenuHelper._normalize(offerta.categoryMacro) ==
            normalizedSelected) {
      return true;
    }

    for (final category in offerta.categories) {
      if (_CategoriaMenuHelper.resolveMacro(category) == selectedMacro) {
        return true;
      }
    }

    return false;
  }

  bool _matchesSelectedSubCategory(OffertaLavoro offerta) {
    final selectedSlug = _selectedCategoriaSlug;
    if (selectedSlug == null || selectedSlug.isEmpty) return true;

    final normalizedSlug = _CategoriaMenuHelper._normalize(selectedSlug);
    final selectedValue = _CategoriaMenuHelper.categoryValueFromSlug(
      selectedSlug,
    );
    final normalizedValue = _CategoriaMenuHelper._normalize(selectedValue);

    if (offerta.categorySub.isNotEmpty) {
      final normalizedOffertaSub = _CategoriaMenuHelper._normalize(
        offerta.categorySub,
      );
      if (normalizedOffertaSub == normalizedSlug ||
          normalizedOffertaSub == normalizedValue) {
        return true;
      }
    }

    for (final category in offerta.categories) {
      final normalizedCategorySlug = _CategoriaMenuHelper._normalize(
        category.slug,
      );
      final normalizedCategoryValue = _CategoriaMenuHelper._normalize(
        _CategoriaMenuHelper.categoryValueFromSlug(category.slug),
      );
      if (normalizedCategorySlug == normalizedSlug ||
          normalizedCategoryValue == normalizedValue) {
        return true;
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _loadInitialData();
  }

  void _handleTabChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSvgTab({
    required int index,
    required String assetPath,
    required String label,
  }) {
    final isSelected = _tabController.index == index;

    return Tab(
      height: 58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isSelected ? _activeMenuColor : _inactiveMenuColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _activeMenuColor : _inactiveMenuColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadInitialData({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
      });
    } else {
      setState(() {
        _errorMessage = null;
        _currentPage = 1;
      });
    }

    final categorieResult = await OfferteLavoroService.getCategorie();
    final offerteResult = await OfferteLavoroService.getOfferte(
      page: 1,
      perPage: 12,
      search: _searchController.text,
      categoryDirection: _selectedJobDirection,
    );

    if (!mounted) return;

    if (offerteResult['success'] == true) {
      final pagination =
          offerteResult['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      setState(() {
        _offerte = (offerteResult['offerte'] as List<OffertaLavoro>);
        _totalPages = (pagination['total_pages'] as num?)?.toInt() ?? 1;
        _isLoading = false;
        _categorie =
            categorieResult['success'] == true
                ? (categorieResult['categorie'] as List<OffertaCategoria>)
                : <OffertaCategoria>[];
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage =
          (offerteResult['message'] ??
                  _OfferteLavoroText.tr(context, 'sendError'))
              .toString();
      _categorie =
          categorieResult['success'] == true
              ? (categorieResult['categorie'] as List<OffertaCategoria>)
              : <OffertaCategoria>[];
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final result = await OfferteLavoroService.getOfferte(
      page: nextPage,
      perPage: 12,
      search: _searchController.text,
      categoryDirection: _selectedJobDirection,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final pagination =
          result['pagination'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      setState(() {
        _offerte.addAll(result['offerte'] as List<OffertaLavoro>);
        _currentPage = nextPage;
        _totalPages =
            (pagination['total_pages'] as num?)?.toInt() ?? _totalPages;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _openDetail(OffertaLavoro offerta) async {
    final result = await OfferteLavoroService.getOfferta(offerta.id);
    if (!mounted) return;

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] ??
                    _OfferteLavoroText.tr(context, 'detailUnavailable'))
                .toString(),
          ),
        ),
      );
      return;
    }

    final detailed = result['offerta'] as OffertaLavoro;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => _OffertaLavoroDetailScreen(
              offerta: detailed,
              onApply: () => _openApplySheet(detailed),
            ),
      ),
    );
  }

  Future<void> _openApplySheet(OffertaLavoro offerta) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CandidaturaSheet(offerta: offerta),
    );

    if (!mounted || result == null) return;

    final success = result['success'] == true;
    final msg = (result['message'] ?? '').toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg.isEmpty
              ? (success
                  ? _OfferteLavoroText.tr(context, 'applicationSent')
                  : _OfferteLavoroText.tr(context, 'applicationError'))
              : msg,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _openSupportWhatsApp({required String message}) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$_wecoopWhatsAppNumber?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_OfferteLavoroText.tr(context, 'cannotOpenWhatsapp')),
      ),
    );
  }

  Future<void> _openInfoModal() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final t =
            (String key, {Map<String, String>? params}) =>
                _OfferteLavoroText.tr(sheetContext, key, params: params);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1282A8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t('supportTitle'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  t('supportDescription'),
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _loadInitialData();
                    },
                    icon: const Icon(Icons.search),
                    label: Text(t('refreshOffers')),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LavoroOrientamentoScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school_outlined),
                    label: Text(t('openOrientation')),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openSupportWhatsApp(
                        message: t('supportWhatsappMessage'),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(t('contactWecoopWhatsapp')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t =
        (String key, {Map<String, String>? params}) =>
            _OfferteLavoroText.tr(context, key, params: params);
    return Scaffold(
      appBar: AppBar(
        title: Text(t('screenTitle')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: _activeMenuColor,
              unselectedLabelColor: _inactiveMenuColor,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _activeMenuColor.withOpacity(0.10),
                border: Border.all(color: _activeMenuColor.withOpacity(0.16)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              tabs: [
                _buildSvgTab(
                  index: 0,
                  assetPath: 'assets/icons/offerte-lavoro/annunci_lavoro.svg',
                  label: t('announcements'),
                ),
                _buildSvgTab(
                  index: 1,
                  assetPath: 'assets/icons/offerte-lavoro/cerco.svg',
                  label: t('seek'),
                ),
                _buildSvgTab(
                  index: 2,
                  assetPath: 'assets/icons/offerte-lavoro/offro.svg',
                  label: t('offer'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: t('offersInfoTooltip'),
            onPressed: _openInfoModal,
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: t('orientationTooltip'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LavoroOrientamentoScreen(),
                ),
              );
            },
            icon: const Icon(Icons.school),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: ANNUNCI LAVORO
          RefreshIndicator(
            onRefresh: _loadInitialData,
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSearchTab(),
          ),
          // Tab 2: CERCO SERVIZIO
          _PubblicaAnnuncioTab(
            categorie: _categorie,
            title: t('seekServiceTitle'),
            subtitle: t('seekServiceSubtitle'),
            fixedType: 'Servizio',
            categoryScope: 'service',
            categoryDirection: 'seek',
            submitButtonText: t('sendServiceRequest'),
          ),
          // Tab 3: OFFRO SERVIZIO
          _PubblicaAnnuncioTab(
            categorie: _categorie,
            title: t('offerServiceTitle'),
            subtitle: t('offerServiceSubtitle'),
            fixedType: 'Servizio',
            categoryScope: 'service',
            categoryDirection: 'offer',
            submitButtonText: t('sendServiceOffer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildSearchBody()],
    );
  }

  Future<void> _openFiltersModal() async {
    final categoriesByMacro = _categorieByMacro;
    final languageCode = Localizations.localeOf(context).languageCode;

    final tempSearchCtrl = TextEditingController(text: _searchController.text);
    String? tempJobDirection = _selectedJobDirection;
    String? tempMacro = _selectedMacroCategoria;
    String? tempCategorySlug = _selectedCategoriaSlug;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        final t =
            (String key, {Map<String, String>? params}) =>
                _OfferteLavoroText.tr(sheetContext, key, params: params);
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tempSelectedSubCategoryValue =
                tempCategorySlug == null
                    ? null
                    : _CategoriaMenuHelper.categoryValueFromSlug(
                      tempCategorySlug!,
                    );

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('filtersTitle'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tempSearchCtrl,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: t('searchHint'),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String?>(
                        initialValue: tempJobDirection,
                        decoration: InputDecoration(labelText: t('scopes')),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(t('all')),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'seek',
                            child: Text(t('seek')),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'offer',
                            child: Text(t('offer')),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            tempJobDirection = value;
                            tempMacro = null;
                            tempCategorySlug = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _CategoryExplorerSelector(
                        categoriesByMacro: categoriesByMacro,
                        languageCode: languageCode,
                        selectedMacro: tempMacro,
                        selectedCategoryValue: tempSelectedSubCategoryValue,
                        macroLabel: t('macroCategories'),
                        subCategoryLabel: t('subCategories'),
                        allMacroText: t('allFeminine'),
                        allSubCategoryText: t('allFeminine'),
                        onMacroChanged: (value) {
                          setModalState(() {
                            tempMacro = value;
                            tempCategorySlug = null;
                          });
                        },
                        onSubCategoryChanged: (value) {
                          final base =
                              tempMacro == null
                                  ? const <OffertaCategoria>[]
                                  : (categoriesByMacro[tempMacro] ??
                                      const <OffertaCategoria>[]);
                          final ordered =
                              _CategoriaMenuHelper.sortSubCategories(
                                base,
                                languageCode,
                              );
                          final selected =
                              _CategoriaMenuHelper.findCategoryByValue(
                                ordered,
                                value,
                              );
                          setModalState(
                            () => tempCategorySlug = selected?.slug,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setModalState(() {
                                  tempSearchCtrl.clear();
                                  tempJobDirection = null;
                                  tempMacro = null;
                                  tempCategorySlug = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: Text(t('clearFilters')),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchController.text = tempSearchCtrl.text;
                                  _selectedJobDirection = tempJobDirection;
                                  _selectedMacroCategoria = tempMacro;
                                  _selectedCategoriaSlug = tempCategorySlug;
                                });
                                Navigator.of(sheetContext).pop();
                                _loadInitialData();
                              },
                              icon: const Icon(Icons.check),
                              label: Text(t('apply')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    tempSearchCtrl.dispose();
  }

  Widget _buildSearchBody() {
    final t =
        (String key, {Map<String, String>? params}) =>
            _OfferteLavoroText.tr(context, key, params: params);
    if (_errorMessage != null) {
      return Column(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          Center(child: Text(_errorMessage!, textAlign: TextAlign.center)),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _loadInitialData,
              child: Text(t('retry')),
            ),
          ),
        ],
      );
    }

    final selectedSubCategoryValue =
        _selectedCategoriaSlug == null
            ? null
            : _CategoriaMenuHelper.categoryValueFromSlug(
              _selectedCategoriaSlug!,
            );
    final displayedOfferte = _offerteFiltrate;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _openFiltersModal,
            icon: const Icon(Icons.tune),
            label: Text(
              (_searchController.text.isNotEmpty ||
                      _selectedJobDirection != null ||
                      _selectedMacroCategoria != null ||
                      selectedSubCategoryValue != null)
                  ? t('activeFilters')
                  : t('openFilters'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (displayedOfferte.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(t('emptyFiltered')),
          )
        else
          ...displayedOfferte.map(
            (offerta) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _openDetail(offerta),
                leading: _buildAuthorAvatar(offerta, radius: 24),
                title: Text(
                  offerta.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (offerta.authorName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              offerta.authorName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (offerta.authorProfileComplete) ...[
                            const SizedBox(width: 6),
                            const _VerifiedBadge(compact: true),
                          ],
                        ],
                      ),
                    ],
                    if (offerta.companyName.isNotEmpty)
                      Text(offerta.companyName),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _DirectionBadge(direction: offerta.categoryDirection),
                        if (offerta.city.isNotEmpty)
                          _MetaChip(
                            icon: Icons.location_on,
                            text: offerta.city,
                          ),
                        if (offerta.contractType.isNotEmpty)
                          _MetaChip(
                            icon: Icons.badge,
                            text: offerta.contractType,
                          ),
                        if (offerta.isFeatured)
                          _MetaChip(icon: Icons.star, text: t('featured')),
                        if (offerta.hasAttachedCv)
                          _MetaChip(
                            icon: Icons.picture_as_pdf_outlined,
                            text: t('attachedCv'),
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        if (_currentPage < _totalPages)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton(
              onPressed: _isLoadingMore ? null : _loadMore,
              child:
                  _isLoadingMore
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(t('loadMore')),
            ),
          ),
      ],
    );
  }

  Widget _buildAuthorAvatar(OffertaLavoro offerta, {double radius = 24}) {
    final avatarUrl = offerta.authorAvatarUrl.trim();
    final initialsSource =
        offerta.authorName.trim().isNotEmpty
            ? offerta.authorName.trim()
            : offerta.companyName.trim();
    final initial =
        initialsSource.isNotEmpty ? initialsSource[0].toUpperCase() : '?';

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAF5F8),
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child:
          avatarUrl.isEmpty
              ? Text(
                initial,
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1282A8),
                ),
              )
              : null,
    );

    if (avatarUrl.isEmpty) {
      return avatar;
    }

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _FullScreenImageViewer(imageUrl: avatarUrl),
          ),
        );
      },
      child: avatar,
    );
  }
}

class _PubblicaAnnuncioTab extends StatefulWidget {
  final List<OffertaCategoria> categorie;
  final String title;
  final String subtitle;
  final String fixedType;
  final String categoryScope;
  final String categoryDirection;
  final String submitButtonText;

  const _PubblicaAnnuncioTab({
    required this.categorie,
    required this.title,
    required this.subtitle,
    required this.fixedType,
    required this.categoryScope,
    required this.categoryDirection,
    required this.submitButtonText,
  });

  @override
  State<_PubblicaAnnuncioTab> createState() => _PubblicaAnnuncioTabState();
}

class _PubblicaAnnuncioTabState extends State<_PubblicaAnnuncioTab> {
  static const String _localCvsKey = 'cv_ai_local_cvs_v1';

  final _formKey = GlobalKey<FormState>();
  final _storage = SecureStorageService();
  final _titoloCtrl = TextEditingController();
  final _cittaCtrl = TextEditingController();
  final _contattoCtrl = TextEditingController();
  final _descrizioneCtrl = TextEditingController();
  final _descrizioneAiCtrl = TextEditingController();
  bool _privacy = false;
  String? _selectedMacroCategoria;
  String? _selectedCategoriaValueEn;
  bool _isSending = false;
  bool _isSuggestingCategory = false;
  bool _isImprovingDescription = false;
  bool _isLoadingGeneratedCvs = false;
  bool _isProfileComplete = false;
  File? _selectedImage;
  List<Map<String, dynamic>> _generatedCvs = const [];
  String? _selectedCvId;
  String? _selectedCvLabel;
  String? _selectedCvPdfUrl;
  String? _selectedCvDocxUrl;
  final _imagePicker = ImagePicker();

  Map<String, List<OffertaCategoria>> get _categorieByMacro {
    return _CategoriaMenuHelper.groupByMacro(widget.categorie);
  }

  @override
  void initState() {
    super.initState();
    _loadProfileCompleteFlag();
    if (widget.categoryDirection == 'seek') {
      _loadGeneratedCvs();
    }
  }

  Future<void> _loadProfileCompleteFlag() async {
    final stored = await _storage.read(key: 'profilo_completo');
    if (!mounted) return;
    setState(() {
      _isProfileComplete = (stored ?? '').toLowerCase() == 'true';
    });
  }

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _cittaCtrl.dispose();
    _contattoCtrl.dispose();
    _descrizioneCtrl.dispose();
    _descrizioneAiCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGeneratedCvs() async {
    setState(() => _isLoadingGeneratedCvs = true);
    final localCached = await _loadLocalCachedCvs();
    final result = await AnnunciSubmissionService.getGeneratedCvs();
    if (!mounted) return;

    if (result['success'] == true) {
      final items =
          ((result['items'] as List?) ?? const <dynamic>[])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
      final merged = _mergeCvEntries(items, localCached);

      setState(() {
        _generatedCvs =
            merged
                .where(
                  (entry) =>
                      ((entry['status'] ?? entry['state'] ?? 'unknown')
                              .toString()
                              .trim()
                              .toLowerCase() ==
                          'generated') &&
                      ((_cvEntryFiles(entry)?['pdfUrl'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty ||
                          (_cvEntryFiles(entry)?['docxUrl'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty),
                )
                .toList();
        _isLoadingGeneratedCvs = false;
      });
      return;
    }

    setState(() {
      _generatedCvs =
          localCached
              .where(
                (entry) =>
                    ((entry['status'] ?? entry['state'] ?? 'unknown')
                            .toString()
                            .trim()
                            .toLowerCase() ==
                        'generated') &&
                    ((_cvEntryFiles(entry)?['pdfUrl'] ?? '')
                            .toString()
                            .trim()
                            .isNotEmpty ||
                        (_cvEntryFiles(entry)?['docxUrl'] ?? '')
                            .toString()
                            .trim()
                            .isNotEmpty),
              )
              .toList();
      _isLoadingGeneratedCvs = false;
    });
  }

  Future<List<Map<String, dynamic>>> _loadLocalCachedCvs() async {
    try {
      final raw = await _storage.read(key: _localCvsKey);
      if (raw == null || raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => e.map((key, value) => MapEntry(key.toString(), value)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  DateTime _parseCvEntryDate(Map<String, dynamic> entry) {
    final updated =
        (entry['updatedAt'] ?? entry['updated_at'] ?? '').toString().trim();
    final created =
        (entry['createdAt'] ?? entry['created_at'] ?? '').toString().trim();
    return DateTime.tryParse(updated) ??
        DateTime.tryParse(created) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<Map<String, dynamic>> _mergeCvEntries(
    List<Map<String, dynamic>> primary,
    List<Map<String, dynamic>> secondary,
  ) {
    final byId = <String, Map<String, dynamic>>{};

    void mergeFrom(List<Map<String, dynamic>> list) {
      for (final entry in list) {
        final id = _cvEntryId(entry).trim();
        final key =
            id.isEmpty
                ? 'fallback_${_parseCvEntryDate(entry).millisecondsSinceEpoch}_${byId.length}'
                : id;
        final previous = byId[key];
        byId[key] = previous == null ? entry : {...previous, ...entry};
      }
    }

    mergeFrom(secondary);
    mergeFrom(primary);

    final merged = byId.values.toList();
    merged.sort((a, b) => _parseCvEntryDate(b).compareTo(_parseCvEntryDate(a)));
    return merged;
  }

  String _cvEntryId(Map<String, dynamic> entry) {
    return (entry['cvId'] ?? entry['cv_id'] ?? entry['id'] ?? '').toString();
  }

  Map<String, dynamic>? _cvEntryFiles(Map<String, dynamic> entry) {
    final files = entry['files'];
    if (files is Map<String, dynamic>) return files;
    if (files is Map) {
      return files.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  String _cvEntryUpdatedAt(Map<String, dynamic> entry) {
    return (entry['updatedAt'] ??
            entry['updated_at'] ??
            entry['createdAt'] ??
            entry['created_at'] ??
            '')
        .toString();
  }

  String _formatCvDate(String raw) {
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return '';
    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  String _cvEntryDisplayLabel(Map<String, dynamic> entry) {
    final payload =
        entry['inputData'] is Map<String, dynamic>
            ? entry['inputData'] as Map<String, dynamic>
            : (entry['payload'] is Map<String, dynamic>
                ? entry['payload'] as Map<String, dynamic>
                : null);
    final personalInfo = payload?['personalInfo'] as Map<String, dynamic>?;
    final firstName =
        (personalInfo?['firstName'] ?? entry['firstName'] ?? '')
            .toString()
            .trim();
    final lastName =
        (personalInfo?['lastName'] ?? entry['lastName'] ?? '')
            .toString()
            .trim();
    final fullName = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');
    final dateLabel = _formatCvDate(_cvEntryUpdatedAt(entry));

    if (fullName.isNotEmpty && dateLabel.isNotEmpty) {
      return '$fullName • CV del $dateLabel';
    }
    if (fullName.isNotEmpty) return fullName;
    if (dateLabel.isNotEmpty) return 'CV del $dateLabel';

    final cvId = _cvEntryId(entry).trim();
    return cvId.isNotEmpty ? 'CV $cvId' : 'CV generato';
  }

  void _selectCv(String? cvId) {
    if (cvId == null || cvId.isEmpty) {
      setState(() {
        _selectedCvId = null;
        _selectedCvLabel = null;
        _selectedCvPdfUrl = null;
        _selectedCvDocxUrl = null;
      });
      return;
    }

    final selected = _generatedCvs.firstWhere(
      (entry) => _cvEntryId(entry) == cvId,
      orElse: () => <String, dynamic>{},
    );
    final files = _cvEntryFiles(selected);
    setState(() {
      _selectedCvId = cvId;
      _selectedCvLabel = _cvEntryDisplayLabel(selected);
      _selectedCvPdfUrl = (files?['pdfUrl'] ?? '').toString().trim();
      _selectedCvDocxUrl = (files?['docxUrl'] ?? '').toString().trim();
    });
  }

  Future<void> _openCreatedAnnouncement(Map<String, dynamic> result) async {
    final data = result['data'];
    final announcementId =
        data is Map<String, dynamic>
            ? (data['submission_id'] as num?)?.toInt()
            : null;
    if (announcementId == null || announcementId <= 0 || !mounted) return;

    final detailResult = await OfferteLavoroService.getOfferta(announcementId);
    if (!mounted || detailResult['success'] != true) return;

    final offerta = detailResult['offerta'];
    if (offerta is! OffertaLavoro) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => _OffertaLavoroDetailScreen(offerta: offerta, onApply: () {}),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento immagine: $e')),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    if (_selectedMacroCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_OfferteLavoroText.tr(context, 'selectMacroCategory')),
        ),
      );
      return false;
    }
    if (_selectedCategoriaValueEn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_OfferteLavoroText.tr(context, 'selectSubCategory')),
        ),
      );
      return false;
    }
    if (_privacy) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_OfferteLavoroText.tr(context, 'acceptPrivacy'))),
    );
    return false;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final initialCategorySlug = _resolveSelectedCategorySlug();
    if (initialCategorySlug == null || initialCategorySlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _OfferteLavoroText.tr(context, 'selectValidSubCategory'),
          ),
        ),
      );
      return;
    }

    final canProceed = await _confirmAiCategoryBeforeSubmit(
      selectedCategorySlug: initialCategorySlug,
    );
    if (!mounted || !canProceed) return;

    final selectedCategorySlug = _resolveSelectedCategorySlug();
    if (selectedCategorySlug == null || selectedCategorySlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sottocategoria non valida dopo il controllo AI'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    // Converti l'immagine in base64 se selezionata
    String? imageBase64;
    if (_selectedImage != null) {
      try {
        final imageBytes = await _selectedImage!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella codifica immagine: $e')),
        );
        setState(() => _isSending = false);
        return;
      }
    }

    final finalDescription =
        _descrizioneAiCtrl.text.trim().isNotEmpty
            ? _descrizioneAiCtrl.text.trim()
            : _descrizioneCtrl.text.trim();

    final result = await AnnunciSubmissionService.submitJobAnnouncement(
      submissionType: widget.fixedType,
      titleOffer: _titoloCtrl.text.trim(),
      city: _cittaCtrl.text.trim(),
      contactPhone: _contattoCtrl.text.trim(),
      description: finalDescription,
      consentPrivacy: _privacy,
      categoryScope: widget.categoryScope,
      categoryDirection: widget.categoryDirection,
      categoryMacro: _selectedMacroCategoria,
      categorySlug: selectedCategorySlug,
      imageBase64: imageBase64,
      cvId: _selectedCvId,
      cvLabel: _selectedCvLabel,
      cvPdfUrl: _selectedCvPdfUrl,
      cvDocxUrl: _selectedCvDocxUrl,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Annuncio inviato con successo!'),
          backgroundColor: Colors.green,
        ),
      );
      _titoloCtrl.clear();
      _cittaCtrl.clear();
      _contattoCtrl.clear();
      _descrizioneCtrl.clear();
      _descrizioneAiCtrl.clear();
      setState(() => _selectedImage = null);
      setState(() {
        _privacy = false;
        _selectedMacroCategoria = null;
        _selectedCategoriaValueEn = null;
        _selectedCvId = null;
        _selectedCvLabel = null;
        _selectedCvPdfUrl = null;
        _selectedCvDocxUrl = null;
      });
      await _openCreatedAnnouncement(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Errore nell\'invio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _confirmAiCategoryBeforeSubmit({
    required String selectedCategorySlug,
  }) async {
    final isServizio = widget.categoryScope == 'service';
    if (!isServizio) return true;

    final descriptionForCheck =
        _descrizioneAiCtrl.text.trim().isNotEmpty
            ? _descrizioneAiCtrl.text.trim()
            : _descrizioneCtrl.text.trim();
    if (descriptionForCheck.length < 12) return true;

    final result =
        await AnnunciSubmissionService.suggestCategoryFromDescription(
          description: descriptionForCheck,
          titleOffer: _titoloCtrl.text.trim(),
          categoryScope: widget.categoryScope,
          categoryDirection: widget.categoryDirection,
        );

    if (!mounted || result['success'] != true) {
      return true;
    }

    final suggestedMacro = (result['category_macro'] ?? '').toString().trim();
    final suggestedSlug = (result['category_slug'] ?? '').toString().trim();
    if (suggestedMacro.isEmpty || suggestedSlug.isEmpty) {
      return true;
    }

    final currentMacro = (_selectedMacroCategoria ?? '').trim();
    final mismatchMacro =
        suggestedMacro.toLowerCase() != currentMacro.toLowerCase();
    final mismatchCategory =
        suggestedSlug.toLowerCase() != selectedCategorySlug.toLowerCase();

    if (!mismatchMacro && !mismatchCategory) {
      return true;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    OffertaCategoria? suggestedCategory;
    OffertaCategoria? currentCategory;
    for (final category in widget.categorie) {
      if (category.slug == suggestedSlug) {
        suggestedCategory = category;
      }
      if (category.slug == selectedCategorySlug) {
        currentCategory = category;
      }
    }

    final currentMacroLabel =
        currentMacro.isNotEmpty
            ? _CategoriaMenuHelper.macroLabel(currentMacro, languageCode)
            : '-';
    final currentCategoryLabel =
        currentCategory != null
            ? _CategoriaMenuHelper.categoryLabel(currentCategory, languageCode)
            : selectedCategorySlug;

    final suggestedMacroLabel = _CategoriaMenuHelper.macroLabel(
      suggestedMacro,
      languageCode,
    );
    final suggestedCategoryLabel =
        suggestedCategory != null
            ? _CategoriaMenuHelper.categoryLabel(
              suggestedCategory,
              languageCode,
            )
            : suggestedSlug;

    final reason = (result['reason'] ?? '').toString().trim();

    final action = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(_OfferteLavoroText.tr(ctx, 'aiCategoryCheck')),
            content: Text(
              _OfferteLavoroText.tr(
                ctx,
                'aiCategoryCheckMessage',
                params: {
                  'currentMacro': currentMacroLabel,
                  'currentCategory': currentCategoryLabel,
                  'suggestedMacro': suggestedMacroLabel,
                  'suggestedCategory': suggestedCategoryLabel,
                  'reasonBlock':
                      reason.isNotEmpty
                          ? '\n\n${_OfferteLavoroText.tr(ctx, 'reasonLabel', params: {'reason': reason})}'
                          : '',
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('cancel'),
                child: Text(_OfferteLavoroText.tr(ctx, 'cancel')),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop('keep'),
                child: Text(_OfferteLavoroText.tr(ctx, 'sendAnyway')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop('apply'),
                child: Text(_OfferteLavoroText.tr(ctx, 'applySuggestion')),
              ),
            ],
          ),
    );

    if (!mounted) return false;
    if (action == 'cancel' || action == null) return false;
    if (action == 'keep') return true;

    final suggestedValue = _CategoriaMenuHelper.categoryValueFromSlug(
      suggestedSlug,
    );
    final selectedInMacro = _CategoriaMenuHelper.findCategoryByValue(
      _categorieByMacro[suggestedMacro] ?? const <OffertaCategoria>[],
      suggestedValue,
    );

    if (selectedInMacro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _OfferteLavoroText.tr(context, 'aiSuggestionNotApplicable'),
          ),
        ),
      );
      return false;
    }

    setState(() {
      _selectedMacroCategoria = suggestedMacro;
      _selectedCategoriaValueEn = suggestedValue;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_OfferteLavoroText.tr(context, 'aiCategoryApplied')),
      ),
    );
    return true;
  }

  Future<void> _improveDescriptionWithAi() async {
    final baseDescription = _descrizioneCtrl.text.trim();
    if (baseDescription.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_OfferteLavoroText.tr(context, 'min12BaseDescription')),
        ),
      );
      return;
    }

    setState(() => _isImprovingDescription = true);

    final result =
        await AnnunciSubmissionService.improveAnnouncementDescription(
          titleOffer: _titoloCtrl.text.trim(),
          city: _cittaCtrl.text.trim(),
          contactPhone: _contattoCtrl.text.trim(),
          description: baseDescription,
          categoryScope: widget.categoryScope,
          categoryDirection: widget.categoryDirection,
        );

    if (!mounted) return;
    setState(() => _isImprovingDescription = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] ??
                    _OfferteLavoroText.tr(
                      context,
                      'improveDescriptionUnavailable',
                    ))
                .toString(),
          ),
        ),
      );
      return;
    }

    final aiDescription = (result['ai_description'] ?? '').toString().trim();
    if (aiDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _OfferteLavoroText.tr(context, 'aiDescriptionUnavailable'),
          ),
        ),
      );
      return;
    }

    _descrizioneAiCtrl.text = aiDescription;
    final source = (result['source'] ?? '').toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          source.isNotEmpty
              ? _OfferteLavoroText.tr(
                context,
                'aiDescriptionGeneratedWithSource',
                params: {'source': source},
              )
              : _OfferteLavoroText.tr(context, 'aiDescriptionGenerated'),
        ),
      ),
    );
  }

  Future<void> _openMyAnnouncementsModal() async {
    final initial = await AnnunciSubmissionService.getMyAnnouncements(
      categoryDirection: widget.categoryDirection,
    );

    if (!mounted) return;

    if (initial['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (initial['message'] ??
                    _OfferteLavoroText.tr(context, 'loadMyAnnouncementsError'))
                .toString(),
          ),
        ),
      );
      return;
    }

    final initialItems =
        ((initial['items'] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        var items = List<Map<String, dynamic>>.from(initialItems);
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoryDirection == 'seek'
                          ? _OfferteLavoroText.tr(
                            context,
                            'mySeekAnnouncements',
                          )
                          : _OfferteLavoroText.tr(
                            context,
                            'myOfferAnnouncements',
                          ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          _OfferteLavoroText.tr(
                            context,
                            'noAnnouncementsToShow',
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            final id = (item['id'] as num?)?.toInt() ?? 0;
                            final title = (item['title'] ?? '').toString();
                            final city = (item['city'] ?? '').toString();
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                title.isNotEmpty
                                    ? title
                                    : _OfferteLavoroText.tr(
                                      context,
                                      'announcementFallback',
                                      params: {'id': '$id'},
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle:
                                  city.isNotEmpty
                                      ? Text(city)
                                      : Text(
                                        _OfferteLavoroText.tr(
                                          context,
                                          'withoutCity',
                                        ),
                                      ),
                              trailing: IconButton(
                                tooltip: _OfferteLavoroText.tr(
                                  context,
                                  'deleteAnnouncementTooltip',
                                ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed:
                                    isDeleting
                                        ? null
                                        : () async {
                                          final confirm =
                                              await showDialog<bool>(
                                                context: sheetContext,
                                                builder:
                                                    (ctx) => AlertDialog(
                                                      title: Text(
                                                        _OfferteLavoroText.tr(
                                                          ctx,
                                                          'deleteAnnouncementTitle',
                                                        ),
                                                      ),
                                                      content: Text(
                                                        _OfferteLavoroText.tr(
                                                          ctx,
                                                          'deleteAnnouncementMessage',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    ctx,
                                                                  ).pop(false),
                                                          child: Text(
                                                            _OfferteLavoroText.tr(
                                                              ctx,
                                                              'cancel',
                                                            ),
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    ctx,
                                                                  ).pop(true),
                                                          child: Text(
                                                            _OfferteLavoroText.tr(
                                                              ctx,
                                                              'delete',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              ) ??
                                              false;

                                          if (!confirm) return;

                                          setModalState(
                                            () => isDeleting = true,
                                          );
                                          final res =
                                              await AnnunciSubmissionService.deleteMyAnnouncement(
                                                id,
                                              );
                                          if (!mounted) return;
                                          setModalState(
                                            () => isDeleting = false,
                                          );

                                          if (res['success'] == true) {
                                            setModalState(
                                              () => items.removeAt(index),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  (res['message'] ??
                                                          _OfferteLavoroText.tr(
                                                            context,
                                                            'announcementDeleted',
                                                          ))
                                                      .toString(),
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  (res['message'] ??
                                                          _OfferteLavoroText.tr(
                                                            context,
                                                            'deleteError',
                                                          ))
                                                      .toString(),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                              ),
                            );
                          },
                        ),
                      ),
                    if (isDeleting)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? _resolveSelectedCategorySlug() {
    if (_selectedCategoriaValueEn == null ||
        _selectedCategoriaValueEn!.isEmpty) {
      return null;
    }

    final categoriesByMacro = _categorieByMacro;
    final inMacro =
        _selectedMacroCategoria == null
            ? const <OffertaCategoria>[]
            : (categoriesByMacro[_selectedMacroCategoria] ??
                const <OffertaCategoria>[]);

    final selectedInMacro = _CategoriaMenuHelper.findCategoryByValue(
      inMacro,
      _selectedCategoriaValueEn,
    );
    if (selectedInMacro != null) {
      return selectedInMacro.slug;
    }

    final selectedGlobal = _CategoriaMenuHelper.findCategoryByValue(
      widget.categorie,
      _selectedCategoriaValueEn,
    );

    return selectedGlobal?.slug ?? _selectedCategoriaValueEn;
  }

  Future<void> _suggestCategoryWithAi() async {
    final description = _descrizioneCtrl.text.trim();
    if (description.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci almeno 12 caratteri nella descrizione'),
        ),
      );
      return;
    }

    setState(() => _isSuggestingCategory = true);

    final result =
        await AnnunciSubmissionService.suggestCategoryFromDescription(
          description: description,
          titleOffer: _titoloCtrl.text.trim(),
          categoryScope: widget.categoryScope,
          categoryDirection: widget.categoryDirection,
        );

    if (!mounted) return;
    setState(() => _isSuggestingCategory = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] ?? 'Suggerimento non disponibile').toString(),
          ),
        ),
      );
      return;
    }

    final macro = (result['category_macro'] ?? '').toString();
    final suggestedSlug = (result['category_slug'] ?? '').toString();
    if (macro.isEmpty || suggestedSlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun suggerimento utile trovato')),
      );
      return;
    }

    OffertaCategoria? suggestedCategory;
    for (final category in widget.categorie) {
      if (category.slug == suggestedSlug) {
        suggestedCategory = category;
        break;
      }
    }

    final suggestedValue =
        suggestedCategory != null
            ? _CategoriaMenuHelper.categoryValueFromSlug(suggestedCategory.slug)
            : _CategoriaMenuHelper.categoryValueFromSlug(suggestedSlug);

    final languageCode = Localizations.localeOf(context).languageCode;
    final macroLabel = _CategoriaMenuHelper.macroLabel(macro, languageCode);
    final categoryLabel =
        suggestedCategory != null
            ? _CategoriaMenuHelper.categoryLabel(
              suggestedCategory,
              languageCode,
            )
            : suggestedSlug;

    final shouldApply =
        await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text(
                  _OfferteLavoroText.tr(ctx, 'applyAiSuggestionQuestion'),
                ),
                content: Text(
                  _OfferteLavoroText.tr(
                    ctx,
                    'setSelectionQuestion',
                    params: {'macro': macroLabel, 'category': categoryLabel},
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(_OfferteLavoroText.tr(ctx, 'no')),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(_OfferteLavoroText.tr(ctx, 'yesApply')),
                  ),
                ],
              ),
        ) ??
        false;

    if (!mounted) return;
    if (shouldApply) {
      setState(() {
        _selectedMacroCategoria = macro;
        _selectedCategoriaValueEn = suggestedValue;
      });
    }

    final reason = (result['reason'] ?? '').toString();
    final source = (result['source'] ?? '').toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !shouldApply
              ? 'Suggerimento non applicato'
              : reason.isNotEmpty
              ? 'Suggerimento ${source.isNotEmpty ? '($source)' : ''}: $reason'
              : 'Categoria suggerita applicata',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesByMacro = _categorieByMacro;
    final languageCode = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(widget.subtitle),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    _isProfileComplete
                        ? Colors.green.shade50
                        : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      _isProfileComplete
                          ? Colors.green.shade200
                          : Colors.amber.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isProfileComplete ? Icons.verified : Icons.info_outline,
                    color:
                        _isProfileComplete
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isProfileComplete
                          ? _OfferteLavoroText.tr(
                            context,
                            'profileCompleteVerified',
                          )
                          : _OfferteLavoroText.tr(
                            context,
                            'profileIncompleteVerified',
                          ),
                      style: TextStyle(
                        color:
                            _isProfileComplete
                                ? Colors.green.shade900
                                : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _openMyAnnouncementsModal,
                icon: const Icon(Icons.list_alt),
                label: Text(_OfferteLavoroText.tr(context, 'myAnnouncements')),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titoloCtrl,
              decoration: InputDecoration(
                labelText: _OfferteLavoroText.tr(context, 'announcementTitle'),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? _OfferteLavoroText.tr(context, 'requiredField')
                          : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _cittaCtrl,
              decoration: InputDecoration(
                labelText: _OfferteLavoroText.tr(context, 'city'),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? _OfferteLavoroText.tr(context, 'requiredField')
                          : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _contattoCtrl,
              decoration: InputDecoration(
                labelText: _OfferteLavoroText.tr(context, 'contactLabel'),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? _OfferteLavoroText.tr(context, 'requiredField')
                          : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _descrizioneCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: _OfferteLavoroText.tr(context, 'description'),
                hintText: _OfferteLavoroText.tr(context, 'descriptionHint'),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().length < 20)
                          ? _OfferteLavoroText.tr(context, 'min20Chars')
                          : null,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    _isImprovingDescription ? null : _improveDescriptionWithAi,
                icon:
                    _isImprovingDescription
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.edit_note),
                label: Text(
                  _isImprovingDescription
                      ? _OfferteLavoroText.tr(context, 'aiImproveRunning')
                      : _OfferteLavoroText.tr(context, 'improveWithAi'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descrizioneAiCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: _OfferteLavoroText.tr(
                  context,
                  'aiDescriptionEditable',
                ),
                hintText: _OfferteLavoroText.tr(context, 'aiDescriptionHint'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    _isSuggestingCategory ? null : _suggestCategoryWithAi,
                icon:
                    _isSuggestingCategory
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.auto_awesome),
                label: Text(
                  _isSuggestingCategory
                      ? _OfferteLavoroText.tr(context, 'aiSuggestionRunning')
                      : _OfferteLavoroText.tr(context, 'suggestCategoryWithAi'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _OfferteLavoroText.tr(context, 'imageOptional'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: Text(_OfferteLavoroText.tr(context, 'change')),
                        ),
                        OutlinedButton.icon(
                          onPressed: _clearImage,
                          icon: const Icon(Icons.delete),
                          label: Text(_OfferteLavoroText.tr(context, 'remove')),
                        ),
                      ],
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: Text(
                        _OfferteLavoroText.tr(context, 'selectImage'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.categoryDirection == 'seek') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal.shade200),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.teal.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _OfferteLavoroText.tr(context, 'attachGeneratedCv'),
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          tooltip: _OfferteLavoroText.tr(context, 'refreshCv'),
                          onPressed:
                              _isLoadingGeneratedCvs ? null : _loadGeneratedCvs,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _OfferteLavoroText.tr(context, 'attachGeneratedCvHint'),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoadingGeneratedCvs)
                      const LinearProgressIndicator(minHeight: 2)
                    else if (_generatedCvs.isEmpty)
                      Text(_OfferteLavoroText.tr(context, 'noGeneratedCv'))
                    else
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedCvId,
                        decoration: InputDecoration(
                          labelText: _OfferteLavoroText.tr(
                            context,
                            'attachCvOptional',
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              _OfferteLavoroText.tr(context, 'noCvAttached'),
                            ),
                          ),
                          ..._generatedCvs.map(
                            (entry) => DropdownMenuItem<String?>(
                              value: _cvEntryId(entry),
                              child: Text(
                                _cvEntryDisplayLabel(entry),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: _selectCv,
                      ),
                    if ((_selectedCvPdfUrl ?? '').isNotEmpty ||
                        (_selectedCvDocxUrl ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if ((_selectedCvPdfUrl ?? '').isNotEmpty)
                            OutlinedButton.icon(
                              onPressed:
                                  () => launchUrl(
                                    Uri.parse(_selectedCvPdfUrl!),
                                    mode: LaunchMode.externalApplication,
                                  ),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: Text(
                                _OfferteLavoroText.tr(context, 'pdfPreview'),
                              ),
                            ),
                          if ((_selectedCvDocxUrl ?? '').isNotEmpty)
                            OutlinedButton.icon(
                              onPressed:
                                  () => launchUrl(
                                    Uri.parse(_selectedCvDocxUrl!),
                                    mode: LaunchMode.externalApplication,
                                  ),
                              icon: const Icon(Icons.description_outlined),
                              label: Text(
                                _OfferteLavoroText.tr(context, 'openWord'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            _CategoryExplorerSelector(
              categoriesByMacro: categoriesByMacro,
              languageCode: languageCode,
              selectedMacro: _selectedMacroCategoria,
              selectedCategoryValue: _selectedCategoriaValueEn,
              macroLabel: _OfferteLavoroText.tr(context, 'macroCategory'),
              subCategoryLabel: _OfferteLavoroText.tr(context, 'subCategories'),
              allMacroText: _OfferteLavoroText.tr(context, 'allFeminine'),
              allSubCategoryText: _OfferteLavoroText.tr(context, 'allFeminine'),
              onMacroChanged: (value) {
                setState(() {
                  _selectedMacroCategoria = value;
                  _selectedCategoriaValueEn = null;
                });
              },
              onSubCategoryChanged: (value) {
                setState(() {
                  _selectedCategoriaValueEn = value;
                });
              },
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _privacy,
              onChanged: (v) => setState(() => _privacy = v == true),
              title: Text(_OfferteLavoroText.tr(context, 'privacyConsent')),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[400],
                  disabledForegroundColor: Colors.grey[600],
                  elevation: 8,
                ),
                icon:
                    _isSending
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.send, size: 26),
                label: Text(
                  _isSending
                      ? _OfferteLavoroText.tr(context, 'sending')
                      : widget.submitButtonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PubblicaAnnuncioSheet extends StatefulWidget {
  const _PubblicaAnnuncioSheet();

  @override
  State<_PubblicaAnnuncioSheet> createState() => _PubblicaAnnuncioSheetState();
}

class _PubblicaAnnuncioSheetState extends State<_PubblicaAnnuncioSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titoloCtrl = TextEditingController();
  final _cittaCtrl = TextEditingController();
  final _contattoCtrl = TextEditingController();
  final _descrizioneCtrl = TextEditingController();
  bool _privacy = false;
  String _tipo = 'Lavoro';
  bool _isSending = false;

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _cittaCtrl.dispose();
    _contattoCtrl.dispose();
    _descrizioneCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    if (_privacy) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_OfferteLavoroText.tr(context, 'acceptPrivacy'))),
    );
    return false;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _isSending = true);

    final result = await AnnunciSubmissionService.submitJobAnnouncement(
      submissionType: _tipo,
      titleOffer: _titoloCtrl.text.trim(),
      city: _cittaCtrl.text.trim(),
      contactPhone: _contattoCtrl.text.trim(),
      description: _descrizioneCtrl.text.trim(),
      consentPrivacy: _privacy,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _OfferteLavoroText.tr(context, 'insertAnnouncement'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _OfferteLavoroText.tr(context, 'insertAnnouncementDescription'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titoloCtrl,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(
                    context,
                    'announcementTitle',
                  ),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? _OfferteLavoroText.tr(context, 'requiredField')
                            : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _cittaCtrl,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'city'),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? _OfferteLavoroText.tr(context, 'requiredField')
                            : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _contattoCtrl,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'contactLabel'),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? _OfferteLavoroText.tr(context, 'requiredField')
                            : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _descrizioneCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'description'),
                  hintText: _OfferteLavoroText.tr(context, 'descriptionHint'),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().length < 20)
                            ? _OfferteLavoroText.tr(context, 'min20Chars')
                            : null,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v == true),
                title: Text(_OfferteLavoroText.tr(context, 'privacyConsent')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[400],
                    disabledForegroundColor: Colors.grey[600],
                    elevation: 8,
                  ),
                  icon:
                      _isSending
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.send, size: 26),
                  label: Text(
                    _isSending
                        ? _OfferteLavoroText.tr(context, 'sending')
                        : _OfferteLavoroText.tr(context, 'sendAnnouncement'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  final String direction;

  const _DirectionBadge({required this.direction});

  @override
  Widget build(BuildContext context) {
    final isSeek = direction == 'seek';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSeek ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSeek ? Colors.orange.shade300 : Colors.green.shade300,
        ),
      ),
      child: Text(
        isSeek ? 'Cerco' : 'Offro',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSeek ? Colors.orange.shade800 : Colors.green.shade800,
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool compact;

  const _VerifiedBadge({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F6EC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF9FD3AF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: compact ? 14 : 16,
            color: const Color(0xFF1F8A4D),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            _OfferteLavoroText.tr(context, 'verifiedProfile'),
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F6B43),
            ),
          ),
        ],
      ),
    );
  }
}

class _OffertaLavoroDetailScreen extends StatelessWidget {
  final OffertaLavoro offerta;
  final VoidCallback onApply;

  const _OffertaLavoroDetailScreen({
    required this.offerta,
    required this.onApply,
  });

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String value) async {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('https://wa.me/${digits.replaceAll('+', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPhoneDialer(String value) async {
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAuthorAvatar(
    BuildContext context,
    OffertaLavoro offerta, {
    double radius = 24,
  }) {
    final avatarUrl = offerta.authorAvatarUrl.trim();
    final initialsSource =
        offerta.authorName.trim().isNotEmpty
            ? offerta.authorName.trim()
            : offerta.companyName.trim();
    final initial =
        initialsSource.isNotEmpty ? initialsSource[0].toUpperCase() : '?';

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAF5F8),
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child:
          avatarUrl.isEmpty
              ? Text(
                initial,
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1282A8),
                ),
              )
              : null,
    );

    if (avatarUrl.isEmpty) {
      return avatar;
    }

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _FullScreenImageViewer(imageUrl: avatarUrl),
          ),
        );
      },
      child: avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_OfferteLavoroText.tr(context, 'detailAnnouncement')),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAuthorAvatar(context, offerta, radius: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (offerta.authorName.isNotEmpty)
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Text(
                                  offerta.authorName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (offerta.authorProfileComplete)
                                  const _VerifiedBadge(),
                              ],
                            ),
                          if (offerta.companyName.isNotEmpty)
                            Text(
                              offerta.companyName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  offerta.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (offerta.imageUrl.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => _FullScreenImageViewer(
                                imageUrl: offerta.imageUrl,
                              ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Image.network(
                            offerta.imageUrl,
                            width: double.infinity,
                            height: constraints.maxWidth > 600 ? 300 : 200,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: constraints.maxWidth > 600 ? 300 : 200,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: constraints.maxWidth > 600 ? 300 : 200,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (offerta.city.isNotEmpty)
                      _MetaChip(icon: Icons.location_on, text: offerta.city),
                    if (offerta.contractType.isNotEmpty)
                      _MetaChip(icon: Icons.badge, text: offerta.contractType),
                    if (offerta.workMode.isNotEmpty)
                      _MetaChip(icon: Icons.workspaces, text: offerta.workMode),
                    if (offerta.languageRequirement.isNotEmpty)
                      _MetaChip(
                        icon: Icons.language,
                        text: offerta.languageRequirement,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (offerta.content.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'description'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(offerta.content),
                  const SizedBox(height: 12),
                ] else if (offerta.requirements.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'description'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(offerta.requirements),
                  const SizedBox(height: 12),
                ] else if (offerta.excerpt.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'description'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(offerta.excerpt),
                  const SizedBox(height: 12),
                ],
                if (offerta.schedule.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'schedule'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(offerta.schedule),
                  const SizedBox(height: 12),
                ],
                if (offerta.salaryRange.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'salary'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(offerta.salaryRange),
                  const SizedBox(height: 12),
                ],
                if (offerta.expiresAt.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'deadline'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(offerta.expiresAt),
                  const SizedBox(height: 12),
                ],
                if (offerta.categories.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'categories'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        offerta.categories
                            .map((c) => Chip(label: Text(c.name)))
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (offerta.hasAttachedCv) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'attachedResume'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    offerta.attachedCvLabel.isNotEmpty
                        ? offerta.attachedCvLabel
                        : _OfferteLavoroText.tr(context, 'attachedCvByAuthor'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (offerta.attachedCvPdfUrl.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () => _openUrl(offerta.attachedCvPdfUrl),
                          icon: const Icon(Icons.visibility_outlined),
                          label: Text(_OfferteLavoroText.tr(context, 'viewCv')),
                        ),
                      if (offerta.attachedCvDocxUrl.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _openUrl(offerta.attachedCvDocxUrl),
                          icon: const Icon(Icons.description_outlined),
                          label: Text(
                            _OfferteLavoroText.tr(context, 'openWord'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (offerta.phoneWhatsapp.isNotEmpty) ...[
                  Text(
                    _OfferteLavoroText.tr(context, 'phone'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(offerta.phoneWhatsapp),
                  const SizedBox(height: 12),
                ],
                if (offerta.phoneWhatsapp.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _openPhoneDialer(offerta.phoneWhatsapp),
                    icon: const Icon(Icons.phone),
                    label: Text(_OfferteLavoroText.tr(context, 'call')),
                  ),
                if (offerta.phoneWhatsapp.isNotEmpty)
                  const SizedBox(height: 10),
                if (offerta.phoneWhatsapp.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(offerta.phoneWhatsapp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.chat),
                    label: Text(
                      _OfferteLavoroText.tr(context, 'contactWhatsapp'),
                    ),
                  ),
                if (offerta.phoneWhatsapp.isNotEmpty &&
                    offerta.sourceUrl.isNotEmpty)
                  const SizedBox(height: 10),
                if (offerta.sourceUrl.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(offerta.sourceUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(
                      _OfferteLavoroText.tr(
                        context,
                        'openOriginalAnnouncement',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidaturaSheet extends StatefulWidget {
  final OffertaLavoro offerta;

  const _CandidaturaSheet({required this.offerta});

  @override
  State<_CandidaturaSheet> createState() => _CandidaturaSheetState();
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.6,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported,
                color: Colors.white70,
                size: 72,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CandidaturaSheetState extends State<_CandidaturaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _privacy = false;
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_privacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_OfferteLavoroText.tr(context, 'acceptPrivacy')),
        ),
      );
      return;
    }

    setState(() => _sending = true);

    final result = await OfferteLavoroService.inviaCandidatura(
      offerId: widget.offerta.id,
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      city: _cityCtrl.text,
      note: _noteCtrl.text,
      consentPrivacy: _privacy,
    );

    if (!mounted) return;
    setState(() => _sending = false);

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Candidatura rapida',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(widget.offerta.title),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'fullName'),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? _OfferteLavoroText.tr(context, 'requiredField')
                            : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'phoneWhatsapp'),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? _OfferteLavoroText.tr(context, 'requiredField')
                            : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'emailOptional'),
                ),
              ),
              TextFormField(
                controller: _cityCtrl,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'cityOptional'),
                ),
              ),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _OfferteLavoroText.tr(context, 'noteOptional'),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v == true),
                title: Text(_OfferteLavoroText.tr(context, 'privacyConsent')),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  child:
                      _sending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            _OfferteLavoroText.tr(context, 'sendApplication'),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

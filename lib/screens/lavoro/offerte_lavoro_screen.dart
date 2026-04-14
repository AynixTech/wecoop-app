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
    'other': {
      'it': 'Altro',
      'en': 'Other',
      'es': 'Otros',
    },
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
    'babysitter': {
      'it': 'Baby sitter',
      'en': 'Babysitter',
      'es': 'Ninera',
    },
    'caregiver': {
      'it': 'Badante',
      'en': 'Caregiver',
      'es': 'Cuidador/a',
    },
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
    'dishwasher': {
      'it': 'Lavapiatti',
      'en': 'Dishwasher',
      'es': 'Lavaplatos',
    },
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
    'pizza-chef': {
      'it': 'Pizzaiolo/a',
      'en': 'Pizza chef',
      'es': 'Pizzero/a',
    },
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
    'driver': {
      'it': 'Autista',
      'en': 'Driver',
      'es': 'Conductor/a',
    },
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
    'welder': {
      'it': 'Saldatore',
      'en': 'Welder',
      'es': 'Soldador/a',
    },
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
    'gardener': {
      'it': 'Giardiniere',
      'en': 'Gardener',
      'es': 'Jardinero/a',
    },
    'electrician': {
      'it': 'Elettricista',
      'en': 'Electrician',
      'es': 'Electricista',
    },
    'plumber': {
      'it': 'Idraulico',
      'en': 'Plumber',
      'es': 'Fontanero/a',
    },
    'painter': {
      'it': 'Imbianchino',
      'en': 'Painter',
      'es': 'Pintor/a',
    },
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
    'teacher': {
      'it': 'Insegnante',
      'en': 'Teacher',
      'es': 'Profesor/a',
    },
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
    'accountant': {
      'it': 'Contabile',
      'en': 'Accountant',
      'es': 'Contable',
    },
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

    final haystack = '${_normalize(category.name)} ${_normalize(category.slug)}';

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
                isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
          Text(
            macroLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
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
                                    onSelected: (_) => onSubCategoryChanged(value),
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
                'Seleziona una macrocategoria per vedere le sottocategorie allineate.',
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
    final selectedValue = _CategoriaMenuHelper.categoryValueFromSlug(selectedSlug);
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
      final normalizedCategorySlug = _CategoriaMenuHelper._normalize(category.slug);
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
      height: 54,
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
          (offerteResult['message'] ?? 'Errore caricamento annunci').toString();
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
            (result['message'] ?? 'Dettaglio non disponibile').toString(),
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
              ? (success ? 'Candidatura inviata' : 'Errore candidatura')
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
      const SnackBar(content: Text('Impossibile aprire WhatsApp')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offerte e Annunci Lavoro',
          style: TextStyle(fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
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
                border: Border.all(
                  color: _activeMenuColor.withOpacity(0.16),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              tabs: [
                _buildSvgTab(
                  index: 0,
                  assetPath: 'assets/icons/offerte-lavoro/annunci_lavoro.svg',
                  label: 'Annunci',
                ),
                _buildSvgTab(
                  index: 1,
                  assetPath: 'assets/icons/offerte-lavoro/cerco.svg',
                  label: 'Cerco',
                ),
                _buildSvgTab(
                  index: 2,
                  assetPath: 'assets/icons/offerte-lavoro/offro.svg',
                  label: 'Offro',
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Servizio orientamento',
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
            title: 'Cerco un servizio',
            subtitle: 'Pubblica una richiesta: ad esempio cerco babysitter, colf o aiuto anziani.',
            fixedType: 'Servizio',
            categoryScope: 'service',
            categoryDirection: 'seek',
            submitButtonText: 'Invia richiesta servizio',
          ),
          // Tab 3: OFFRO SERVIZIO
          _PubblicaAnnuncioTab(
            categorie: _categorie,
            title: 'Offro un servizio',
            subtitle: 'Pubblica la tua disponibilita professionale: ad esempio offro servizio di babysitter.',
            fixedType: 'Servizio',
            categoryScope: 'service',
            categoryDirection: 'offer',
            submitButtonText: 'Invia offerta servizio',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vuoi cercare lavoro?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sfoglia le offerte disponibili o contatta WECOOP per supporto.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadInitialData,
                    icon: const Icon(Icons.search),
                    label: const Text('Aggiorna'),
                  ),
                  TextButton.icon(
                    onPressed:
                        () => _openSupportWhatsApp(
                          message:
                              'Ciao WECOOP, vorrei informazioni per cercare lavoro o attivare servizi dedicati.',
                        ),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSearchBody(),
      ],
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tempSelectedSubCategoryValue =
                tempCategorySlug == null
                    ? null
                    : _CategoriaMenuHelper.categoryValueFromSlug(tempCategorySlug!);

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
                        'Filtri annunci',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tempSearchCtrl,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Cerca: baby sitter, badante, colf, OSS...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String?>(
                        initialValue: tempJobDirection,
                        decoration: const InputDecoration(labelText: 'Ambiti'),
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tutti'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'seek',
                            child: Text('Cerco'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'offer',
                            child: Text('Offro'),
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
                        macroLabel: 'Macrocategorie',
                        subCategoryLabel: 'Sottocategorie',
                        allMacroText: 'Tutte',
                        allSubCategoryText: 'Tutte',
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
                          final ordered = _CategoriaMenuHelper.sortSubCategories(
                            base,
                            languageCode,
                          );
                          final selected = _CategoriaMenuHelper.findCategoryByValue(
                            ordered,
                            value,
                          );
                          setModalState(() => tempCategorySlug = selected?.slug);
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
                              label: const Text('Pulisci filtri'),
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
                              label: const Text('Applica'),
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
              child: const Text('Riprova'),
            ),
          ),
        ],
      );
    }

    final selectedSubCategoryValue =
      _selectedCategoriaSlug == null
        ? null
        : _CategoriaMenuHelper.categoryValueFromSlug(_selectedCategoriaSlug!);
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
                  ? 'Filtri (attivi)'
                  : 'Apri filtri',
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
            child: const Text(
              'Nessun annuncio disponibile con questi filtri. Prova categorie come Pulizie/Limpieza, Badante o Baby sitter.',
            ),
          )
        else
          ...displayedOfferte.map(
            (offerta) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () => _openDetail(offerta),
                title: Text(
                  offerta.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          const _MetaChip(
                            icon: Icons.star,
                            text: 'In evidenza',
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
                      : const Text('Carica altri annunci'),
            ),
          ),
      ],
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
  final _formKey = GlobalKey<FormState>();
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
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  Map<String, List<OffertaCategoria>> get _categorieByMacro {
    return _CategoriaMenuHelper.groupByMacro(widget.categorie);
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
        const SnackBar(content: Text('Seleziona una macrocategoria')),
      );
      return false;
    }
    if (_selectedCategoriaValueEn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una sottocategoria')),
      );
      return false;
    }
    if (_privacy) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Devi accettare il consenso privacy')),
    );
    return false;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final initialCategorySlug = _resolveSelectedCategorySlug();
    if (initialCategorySlug == null || initialCategorySlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una sottocategoria valida')),
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
      });
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

    final result = await AnnunciSubmissionService.suggestCategoryFromDescription(
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

    final suggestedMacroLabel =
        _CategoriaMenuHelper.macroLabel(suggestedMacro, languageCode);
    final suggestedCategoryLabel =
        suggestedCategory != null
            ? _CategoriaMenuHelper.categoryLabel(suggestedCategory, languageCode)
            : suggestedSlug;

    final reason = (result['reason'] ?? '').toString().trim();

    final action = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Controllo AI categoria'),
            content: Text(
              'La categoria selezionata sembra non coerente con la descrizione.\n\n'
              'Selezione attuale:\n'
              '• Macrocategoria: $currentMacroLabel\n'
              '• Sottocategoria: $currentCategoryLabel\n\n'
              'Suggerimento AI:\n'
              '• Macrocategoria: $suggestedMacroLabel\n'
              '• Sottocategoria: $suggestedCategoryLabel'
              '${reason.isNotEmpty ? '\n\nMotivo: $reason' : ''}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop('cancel'),
                child: const Text('Annulla'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop('keep'),
                child: const Text('Invia comunque'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop('apply'),
                child: const Text('Applica suggerimento'),
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
        const SnackBar(
          content: Text(
            'Suggerimento AI non applicabile alle categorie disponibili',
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
      const SnackBar(content: Text('Categoria AI applicata')),
    );
    return true;
  }

  Future<void> _improveDescriptionWithAi() async {
    final baseDescription = _descrizioneCtrl.text.trim();
    if (baseDescription.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci almeno 12 caratteri nella descrizione base'),
        ),
      );
      return;
    }

    setState(() => _isImprovingDescription = true);

    final result = await AnnunciSubmissionService.improveAnnouncementDescription(
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
        SnackBar(content: Text((result['message'] ?? 'Impossibile migliorare la descrizione').toString())),
      );
      return;
    }

    final aiDescription = (result['ai_description'] ?? '').toString().trim();
    if (aiDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessuna descrizione AI disponibile')),
      );
      return;
    }

    _descrizioneAiCtrl.text = aiDescription;
    final source = (result['source'] ?? '').toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          source.isNotEmpty
              ? 'Descrizione AI generata ($source). Puoi modificarla prima di inviare.'
              : 'Descrizione AI generata. Puoi modificarla prima di inviare.',
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
            (initial['message'] ?? 'Impossibile caricare i tuoi annunci').toString(),
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
                          ? 'Le mie richieste (Cerco)'
                          : 'Le mie offerte (Offro)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text('Non hai ancora annunci da mostrare.'),
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
                                title.isNotEmpty ? title : 'Annuncio #$id',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle:
                                  city.isNotEmpty
                                      ? Text(city)
                                      : const Text('Senza citta'),
                              trailing: IconButton(
                                tooltip: 'Elimina annuncio',
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
                                                      title: const Text(
                                                        'Eliminare annuncio?',
                                                      ),
                                                      content: const Text(
                                                        'Questa azione spostera l\'annuncio nel cestino.',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () => Navigator.of(
                                                                ctx,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'Annulla',
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed:
                                                              () => Navigator.of(
                                                                ctx,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Elimina',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              ) ??
                                              false;

                                          if (!confirm) return;

                                          setModalState(() => isDeleting = true);
                                          final res =
                                              await AnnunciSubmissionService.deleteMyAnnouncement(
                                                id,
                                              );
                                          if (!mounted) return;
                                          setModalState(() => isDeleting = false);

                                          if (res['success'] == true) {
                                            setModalState(
                                              () => items.removeAt(index),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      (res['message'] ??
                                                              'Annuncio eliminato')
                                                          .toString(),
                                                    ),
                                                  ),
                                                );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      (res['message'] ??
                                                              'Errore eliminazione')
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
    if (_selectedCategoriaValueEn == null || _selectedCategoriaValueEn!.isEmpty) {
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

    final result = await AnnunciSubmissionService.suggestCategoryFromDescription(
      description: description,
      titleOffer: _titoloCtrl.text.trim(),
      categoryScope: widget.categoryScope,
      categoryDirection: widget.categoryDirection,
    );

    if (!mounted) return;
    setState(() => _isSuggestingCategory = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((result['message'] ?? 'Suggerimento non disponibile').toString())),
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
            ? _CategoriaMenuHelper.categoryLabel(suggestedCategory, languageCode)
            : suggestedSlug;

    final shouldApply =
        await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Applicare suggerimento AI?'),
                content: Text(
                  'Vuoi impostare questa selezione?\n'
                  'Macrocategoria: $macroLabel\n'
                  'Sottocategoria: $categoryLabel',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('No'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Si, applica'),
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
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _openMyAnnouncementsModal,
                icon: const Icon(Icons.list_alt),
                label: const Text('I miei annunci'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titoloCtrl,
              decoration: const InputDecoration(labelText: 'Titolo annuncio'),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obbligatorio'
                          : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _cittaCtrl,
              decoration: const InputDecoration(labelText: 'Citta'),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obbligatorio'
                          : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _contattoCtrl,
              decoration: const InputDecoration(
                labelText: 'Telefono o email di contatto',
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Campo obbligatorio'
                          : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _descrizioneCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                hintText:
                    'Descrivi mansione/servizio, orari e requisiti principali',
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().length < 20)
                          ? 'Inserisci almeno 20 caratteri'
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
                      ? 'Miglioramento AI in corso...'
                      : 'Migliora descrizione con AI',
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descrizioneAiCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Descrizione AI (modificabile)',
                hintText:
                    'La descrizione migliorata comparira qui. Puoi modificarla prima di inviare.',
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSuggestingCategory ? null : _suggestCategoryWithAi,
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
                      ? 'Suggerimento AI in corso...'
                      : 'Suggerisci categoria con AI',
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
                  const Text(
                    'Immagine o foto (Opzionale)',
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
                          label: const Text('Cambia'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _clearImage,
                          icon: const Icon(Icons.delete),
                          label: const Text('Rimuovi'),
                        ),
                      ],
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Seleziona immagine'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _CategoryExplorerSelector(
              categoriesByMacro: categoriesByMacro,
              languageCode: languageCode,
              selectedMacro: _selectedMacroCategoria,
              selectedCategoryValue: _selectedCategoriaValueEn,
              macroLabel: 'Macrocategoria',
              subCategoryLabel: 'Sottocategorie',
              allMacroText: 'Tutte',
              allSubCategoryText: 'Tutte',
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
              title: const Text('Accetto il trattamento dei dati personali'),
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
                  _isSending ? 'Invio in corso...' : widget.submitButtonText,
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
      const SnackBar(content: Text('Devi accettare il consenso privacy')),
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
                'Inserisci annuncio',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Compila i dati e invia la richiesta a WECOOP per la pubblicazione.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titoloCtrl,
                decoration: const InputDecoration(labelText: 'Titolo annuncio'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _cittaCtrl,
                decoration: const InputDecoration(labelText: 'Citta'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _contattoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Telefono o email di contatto',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _descrizioneCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  hintText:
                      'Descrivi mansione/servizio, orari e requisiti principali',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().length < 20)
                            ? 'Inserisci almeno 20 caratteri'
                            : null,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v == true),
                title: const Text('Accetto il trattamento dei dati personali'),
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
                    _isSending ? 'Invio in corso...' : 'Invia annuncio',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dettaglio annuncio',
          style: TextStyle(fontSize: 16),
        ),
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
          Text(
            offerta.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (offerta.companyName.isNotEmpty)
            Text(
              offerta.companyName,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          const SizedBox(height: 12),
          if (offerta.imageUrl.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullScreenImageViewer(imageUrl: offerta.imageUrl),
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
                            child: Icon(Icons.image_not_supported, size: 48),
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
            const Text(
              'Descrizione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.content),
            const SizedBox(height: 12),
          ] else if (offerta.requirements.isNotEmpty) ...[
            const Text(
              'Descrizione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.requirements),
            const SizedBox(height: 12),
          ] else if (offerta.excerpt.isNotEmpty) ...[
            const Text(
              'Descrizione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.excerpt),
            const SizedBox(height: 12),
          ],
          if (offerta.schedule.isNotEmpty) ...[
            const Text('Orari', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(offerta.schedule),
            const SizedBox(height: 12),
          ],
          if (offerta.salaryRange.isNotEmpty) ...[
            const Text(
              'Retribuzione',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.salaryRange),
            const SizedBox(height: 12),
          ],
          if (offerta.expiresAt.isNotEmpty) ...[
            const Text(
              'Scadenza',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(offerta.expiresAt),
            const SizedBox(height: 12),
          ],
          if (offerta.categories.isNotEmpty) ...[
            const Text(
              'Categorie',
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
          if (offerta.phoneWhatsapp.isNotEmpty) ...[
            const Text(
              'Telefono',
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
              label: const Text('Chiama'),
            ),
          if (offerta.phoneWhatsapp.isNotEmpty) const SizedBox(height: 10),
          if (offerta.phoneWhatsapp.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _openWhatsApp(offerta.phoneWhatsapp),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.chat),
              label: const Text('Contatta su WhatsApp'),
            ),
          if (offerta.phoneWhatsapp.isNotEmpty && offerta.sourceUrl.isNotEmpty)
            const SizedBox(height: 10),
          if (offerta.sourceUrl.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => _openUrl(offerta.sourceUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Apri annuncio originale'),
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
        const SnackBar(content: Text('Devi accettare il consenso privacy')),
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
                decoration: const InputDecoration(labelText: 'Nome e cognome'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefono / WhatsApp',
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Campo obbligatorio'
                            : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (opzionale)',
                ),
              ),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Citta (opzionale)',
                ),
              ),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nota (opzionale)',
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _privacy,
                onChanged: (v) => setState(() => _privacy = v == true),
                title: const Text('Accetto il trattamento dei dati personali'),
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
                          : const Text('Invia candidatura'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CvAiScreen extends StatefulWidget {
  const CvAiScreen({super.key});

  @override
  State<CvAiScreen> createState() => _CvAiScreenState();
}

class _CvAiScreenState extends State<CvAiScreen> {
  static const int _totalSteps = 7;
  static const String _draftKey = 'cv_ai_draft_v1';
  static const String _cvApiBase =
      'https://www.wecoop.org/wp-json/wecoop/v1/cv';
  static const String _cvTemplatesEndpoint =
      'https://www.wecoop.org/wp-json/wecoop/v1/cv/templates';
  static const String _cvPreviewEndpoint =
      'https://www.wecoop.org/wp-json/wecoop/v1/cv/preview';
  static const Duration _pollInterval = Duration(seconds: 3);
  static const Duration _maxPollingDuration = Duration(seconds: 90);
  static const int _maxBackendPayloadBytes = 300 * 1024;
  static const int _maxPhotoRawBytes = 70 * 1024;

  final _storage = SecureStorageService();
  final _imagePicker = ImagePicker();

  int _currentStep = 0;
  bool _isGenerating = false;
  bool _isGenerated = false;
  String? _generatedCvId;
  String? _generatedPdfUrl;
  String? _generatedDocxUrl;

  String? _photoPath;

  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _dataNascitaController = TextEditingController();
  final _nazionalitaController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  final _eduTitoloController = TextEditingController();
  final _eduIstitutoController = TextEditingController();
  final _eduPaeseController = TextEditingController();
  final _eduDataInizioController = TextEditingController();
  final _eduDataFineController = TextEditingController();
  final _eduDescrizioneController = TextEditingController();

  final _expRuoloController = TextEditingController();
  final _expAziendaController = TextEditingController();
  final _expPaeseController = TextEditingController();
  final _expDataInizioController = TextEditingController();
  final _expDataFineController = TextEditingController();
  final _expDescrizioneController = TextEditingController();

  String _selectedLanguage = 'Italiano';
  String _livelloLingua = 'Intermedio';

  final _skillController = TextEditingController();

  final _obiettivoController = TextEditingController();
  final _paeseLavoroController = TextEditingController();
  final _disponibilitaController = TextEditingController();
  final _settoreController = TextEditingController();
  bool _vuoleFormazione = false;

  String _cvModel = 'formal';
  bool _includePhoto = true;
  String _cvLanguage = 'it';
  bool _isLoadingTemplates = false;
  String? _templatesError;
  bool _isLoadingTemplatePreview = false;
  String? _templatePreviewError;
  String? _templatePreviewHtml;

  final List<Map<String, String>> _educations = [];
  final List<Map<String, String>> _experiences = [];
  final List<Map<String, String>> _languages = [];
  final List<String> _skills = [];
  final List<Map<String, String>> _documents = [];
  final List<Map<String, dynamic>> _cvTemplates = [];
  late final WebViewController _templatePreviewController;

  @override
  void initState() {
    super.initState();
    _templatePreviewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white);
    _loadDraft();
    _loadCvTemplates();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _dataNascitaController.dispose();
    _nazionalitaController.dispose();
    _indirizzoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _eduTitoloController.dispose();
    _eduIstitutoController.dispose();
    _eduPaeseController.dispose();
    _eduDataInizioController.dispose();
    _eduDataFineController.dispose();
    _eduDescrizioneController.dispose();
    _expRuoloController.dispose();
    _expAziendaController.dispose();
    _expPaeseController.dispose();
    _expDataInizioController.dispose();
    _expDataFineController.dispose();
    _expDescrizioneController.dispose();
    _skillController.dispose();
    _obiettivoController.dispose();
    _paeseLavoroController.dispose();
    _disponibilitaController.dispose();
    _settoreController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final raw = await _storage.read(key: _draftKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final draft = jsonDecode(raw) as Map<String, dynamic>;
      _nomeController.text = draft['nome']?.toString() ?? '';
      _cognomeController.text = draft['cognome']?.toString() ?? '';
      _dataNascitaController.text = draft['data_nascita']?.toString() ?? '';
      _nazionalitaController.text = draft['nazionalita']?.toString() ?? '';
      _indirizzoController.text = draft['indirizzo']?.toString() ?? '';
      _telefonoController.text = draft['telefono']?.toString() ?? '';
      _emailController.text = draft['email']?.toString() ?? '';
      _photoPath = draft['photo_path']?.toString();

      _obiettivoController.text = draft['obiettivo']?.toString() ?? '';
      _paeseLavoroController.text = draft['paese_lavoro']?.toString() ?? '';
      _disponibilitaController.text = draft['disponibilita']?.toString() ?? '';
      _settoreController.text = draft['settore']?.toString() ?? '';
      _vuoleFormazione = draft['vuole_formazione'] == true;

      _cvModel = _normalizedTemplateId(
        draft['cv_model']?.toString() ?? 'formal',
      );
      _cvLanguage = _normalizedCvLanguage(
        draft['cv_language']?.toString() ?? 'it',
      );
      _includePhoto = draft['include_photo'] != false;

      _educations
        ..clear()
        ..addAll(_toMapList(draft['educations']));
      _experiences
        ..clear()
        ..addAll(_toMapList(draft['experiences']));
      _languages
        ..clear()
        ..addAll(
          _toMapList(draft['languages']).map((item) {
            final level = item['livello'];
            if (level == null || level.isEmpty) return item;
            return {...item, 'livello': _normalizedLanguageLevel(level)};
          }),
        );
      _documents
        ..clear()
        ..addAll(_toMapList(draft['documents']));
      _skills
        ..clear()
        ..addAll(
          (draft['skills'] as List<dynamic>? ?? []).map((e) => e.toString()),
        );

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('cvAiDraftLoaded'),
          ),
        ),
      );
    } catch (_) {}
  }

  List<Map<String, String>> _toMapList(dynamic value) {
    final list = value as List<dynamic>? ?? [];
    return list
        .map((entry) {
          if (entry is Map) {
            return entry.map(
              (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
            );
          }
          return <String, String>{};
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static const List<String> _languageLevelOptions = [
    'Base',
    'Elementare',
    'Intermedio',
    'Buono',
    'Ottimo',
    'Madrelingua',
  ];

  static const List<String> _spokenLanguageOptions = [
    'Italiano',
    'Espanol',
    'English',
    'Francais',
    'Deutsch',
    'Portugues',
    'Nederlands',
    'Polski',
    'Romana',
    'Ukrainska',
    'Russkiy',
    'Ellinika',
    'Svenska',
    'Cesky',
    'Magyar',
    'Turkce',
  ];

  static const List<String> _cvLanguageOptions = [
    'it',
    'es',
    'en',
    'fr',
    'de',
    'pt',
    'nl',
    'pl',
    'ro',
    'uk',
    'ru',
    'el',
    'sv',
    'cs',
    'hu',
    'tr',
  ];

  String _mapLegacyLanguageLevel(String value) {
    switch (value) {
      case 'A1':
        return 'Base';
      case 'A2':
        return 'Elementare';
      case 'B1':
        return 'Intermedio';
      case 'B2':
        return 'Buono';
      case 'C1':
        return 'Ottimo';
      case 'C2':
        return 'Madrelingua';
      default:
        return value;
    }
  }

  String _normalizedLanguageLevel(String value) {
    final normalized = _mapLegacyLanguageLevel(value);
    if (_languageLevelOptions.contains(normalized)) return normalized;
    return 'Intermedio';
  }

  String _normalizedCvLanguage(String value) {
    final normalized = value.toLowerCase().trim();
    if (_cvLanguageOptions.contains(normalized)) return normalized;
    return 'it';
  }

  String _normalizedSpokenLanguage(String value) {
    if (_spokenLanguageOptions.contains(value)) return value;
    return 'Italiano';
  }

  String _normalizedTemplateId(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'europass':
      case 'modern':
      case 'simple':
        return 'formal';
      default:
        return normalized;
    }
  }

  Future<void> _loadCvTemplates() async {
    setState(() {
      _isLoadingTemplates = true;
      _templatesError = null;
    });

    try {
      final headers = await _buildAuthHeaders();
      final response = await HttpClientService.get(
        Uri.parse(_cvTemplatesEndpoint),
        headers: headers,
      );
      final body = HttpClientService.decodeJsonResponse(response);

      if (response.statusCode != 200 || body is! Map<String, dynamic>) {
        setState(() {
          _templatesError = 'Impossibile caricare i template CV';
          _isLoadingTemplates = false;
        });
        return;
      }

      final items = body['items'] as List<dynamic>? ?? [];
      final parsedTemplates =
          items
              .whereType<Map>()
              .map(
                (e) => {
                  'id': e['id']?.toString() ?? '',
                  'name': e['name']?.toString() ?? '',
                  'htmlUrl': e['htmlUrl']?.toString() ?? '',
                  'cssUrl': e['cssUrl']?.toString() ?? '',
                  'isDefault': e['isDefault'] == true,
                },
              )
              .where((e) => (e['id'] as String).isNotEmpty)
              .toList();

      final ids = parsedTemplates.map((e) => e['id'] as String).toSet();
      final defaultTemplate = body['defaultTemplate']?.toString() ?? '';
      var selected = _normalizedTemplateId(_cvModel);

      if (!ids.contains(selected)) {
        if (defaultTemplate.isNotEmpty && ids.contains(defaultTemplate)) {
          selected = defaultTemplate;
        } else if (parsedTemplates.isNotEmpty) {
          selected = parsedTemplates.first['id'] as String;
        }
      }

      setState(() {
        _cvTemplates
          ..clear()
          ..addAll(parsedTemplates);
        _cvModel = selected;
        _isLoadingTemplates = false;
      });
      await _saveDraft();
    } catch (_) {
      setState(() {
        _templatesError = 'Errore di rete durante il caricamento template';
        _isLoadingTemplates = false;
      });
    }
  }

  Future<void> _loadTemplatePreview() async {
    final templateId = _normalizedTemplateId(_cvModel);
    if (templateId.isEmpty) return;

    setState(() {
      _isLoadingTemplatePreview = true;
      _templatePreviewError = null;
    });

    try {
      final headers = await _buildAuthHeaders();
      final payloadJson = jsonEncode(await _buildCvGeneratePayload());
      final uri = Uri.parse(
        '$_cvPreviewEndpoint?template=${Uri.encodeQueryComponent(templateId)}',
      );

      _logCvGeneration(
        'cv_preview_request_sent',
        data: {
          'endpoint': uri.toString(),
          'template': templateId,
          'payloadBytes': utf8.encode(payloadJson).length,
        },
      );

      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: payloadJson,
      );
      final body = HttpClientService.decodeJsonResponse(response);

      _logCvGeneration(
        'cv_preview_response_received',
        data: {
          'statusCode': response.statusCode,
          'ok': body is Map<String, dynamic> ? body['ok'] : null,
          'requestId': body is Map<String, dynamic> ? body['requestId'] : null,
        },
      );

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final ok = body['ok'] == true;
        final html = body['html']?.toString();
        if (ok && html != null && html.trim().isNotEmpty) {
          await _templatePreviewController.loadHtmlString(html);
          if (!mounted) return;
          setState(() {
            _templatePreviewHtml = html;
            _isLoadingTemplatePreview = false;
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _templatePreviewError = 'Anteprima non disponibile per questo template';
        _isLoadingTemplatePreview = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _templatePreviewError = 'Errore nel caricamento anteprima template';
        _isLoadingTemplatePreview = false;
      });
    }
  }

  Future<void> _openTemplatePreviewModal() async {
    if (_templatePreviewHtml == null || _templatePreviewHtml!.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anteprima non ancora disponibile')),
      );
      return;
    }

    final modalController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white);
    await modalController.loadHtmlString(_templatePreviewHtml!);

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.6,
          maxChildSize: 0.98,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Anteprima template',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 1.1,
                        child: WebViewWidget(controller: modalController),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveDraft() async {
    final draft = {
      'nome': _nomeController.text,
      'cognome': _cognomeController.text,
      'data_nascita': _dataNascitaController.text,
      'nazionalita': _nazionalitaController.text,
      'indirizzo': _indirizzoController.text,
      'telefono': _telefonoController.text,
      'email': _emailController.text,
      'photo_path': _photoPath,
      'educations': _educations,
      'experiences': _experiences,
      'languages': _languages,
      'skills': _skills,
      'documents': _documents,
      'obiettivo': _obiettivoController.text,
      'paese_lavoro': _paeseLavoroController.text,
      'disponibilita': _disponibilitaController.text,
      'settore': _settoreController.text,
      'vuole_formazione': _vuoleFormazione,
      'cv_model': _cvModel,
      'cv_language': _normalizedCvLanguage(_cvLanguage),
      'include_photo': _includePhoto,
    };

    await _storage.write(key: _draftKey, value: jsonEncode(draft));
  }

  DateTime? _tryParseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDateForController(
    TextEditingController controller, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final minDate = firstDate ?? DateTime(1950);
    final maxDate = lastDate ?? DateTime(2100);

    var initialDate = _tryParseDate(controller.text) ?? now;
    if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }
    if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'Seleziona data',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );

    if (picked == null) return;

    setState(() {
      controller.text = _formatDate(picked);
    });
    await _saveDraft();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _imagePicker.pickImage(
      source: source,
      maxWidth: 720,
      imageQuality: 68,
      preferredCameraDevice: CameraDevice.front,
    );

    if (file == null) return;

    setState(() {
      _photoPath = file.path;
    });
    await _saveDraft();
  }

  Future<void> _showPhotoSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Carica da galleria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Scatta foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickPhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    setState(() {
      for (final file in result.files) {
        _documents.add({'name': file.name, 'path': file.path ?? ''});
      }
    });
    await _saveDraft();
  }

  Map<String, dynamic> _cvGenerationSummary() {
    final selectedTemplate = _cvTemplates.firstWhere(
      (e) => (e['id']?.toString() ?? '') == _normalizedTemplateId(_cvModel),
      orElse: () => <String, dynamic>{},
    );

    return {
      'step': _currentStep,
      'cvModel': _normalizedTemplateId(_cvModel),
      'cvLanguage': _normalizedCvLanguage(_cvLanguage),
      'includePhoto': _includePhoto,
      'hasPhoto': _photoPath != null,
      'hasTemplateCss':
          (selectedTemplate['cssUrl']?.toString().isNotEmpty ?? false),
      'educationCount': _educations.length,
      'experienceCount': _experiences.length,
      'languagesCount': _languages.length,
      'skillsCount': _skills.length,
      'documentsCount': _documents.length,
    };
  }

  String? _isoDateFromController(TextEditingController controller) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    final parsed = _tryParseDate(raw);
    if (parsed == null) return null;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  String _guessImageMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  Future<Map<String, String>?> _photoPayloadFromPath() async {
    if (!_includePhoto || _photoPath == null || _photoPath!.trim().isEmpty) {
      return null;
    }

    try {
      final path = _photoPath!;
      final rawBytes = await File(path).readAsBytes();
      if (rawBytes.isEmpty) return null;

      var bestBytes = rawBytes;
      var mimeType = _guessImageMimeType(path);

      final decoded = img.decodeImage(rawBytes);
      if (decoded != null) {
        final resized =
            decoded.width > 720 ? img.copyResize(decoded, width: 720) : decoded;

        // Keep reducing quality until the image fits a safe payload budget.
        for (var quality = 82; quality >= 45; quality -= 7) {
          final candidate = img.encodeJpg(resized, quality: quality);
          if (candidate.length <= _maxPhotoRawBytes) {
            bestBytes = candidate;
            mimeType = 'image/jpeg';
            break;
          }
          if (candidate.length < bestBytes.length) {
            bestBytes = candidate;
            mimeType = 'image/jpeg';
          }
        }
      }

      final photoBase64 = base64Encode(bestBytes);
      return {
        'photoBase64': photoBase64,
        // Backward compatibility: some renderers expect `photo` instead.
        'photo': photoBase64,
        'photoMimeType': mimeType,
        'photoFileName': path.split('/').last,
      };
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _buildCvGeneratePayload() async {
    final photoPayload = await _photoPayloadFromPath();
    final selectedTemplate = _cvTemplates.firstWhere(
      (e) => (e['id']?.toString() ?? '') == _normalizedTemplateId(_cvModel),
      orElse: () => <String, dynamic>{},
    );

    final personalInfo = {
      'firstName': _nomeController.text.trim(),
      'lastName': _cognomeController.text.trim(),
      if (_isoDateFromController(_dataNascitaController) != null)
        'birthDate': _isoDateFromController(_dataNascitaController),
      'nationality': _nazionalitaController.text.trim(),
      'phone': _telefonoController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _indirizzoController.text.trim(),
      if (photoPayload != null) ...photoPayload,
    };

    final education =
        _educations
            .map(
              (e) => {
                'title': e['titolo'] ?? '',
                'institution': e['istituto'] ?? '',
                'country': e['paese'] ?? '',
                if (_tryParseDate(e['inizio'] ?? '') != null)
                  'startDate': _isoDateFromString(e['inizio']!),
                if (_tryParseDate(e['fine'] ?? '') != null)
                  'endDate': _isoDateFromString(e['fine']!),
                'description': e['descrizione'] ?? '',
              },
            )
            .toList();

    final experience =
        _experiences
            .map(
              (e) => {
                'role': e['ruolo'] ?? '',
                'company': e['azienda'] ?? '',
                'country': e['paese'] ?? '',
                if (_tryParseDate(e['inizio'] ?? '') != null)
                  'startDate': _isoDateFromString(e['inizio']!),
                if (_tryParseDate(e['fine'] ?? '') != null)
                  'endDate': _isoDateFromString(e['fine']!),
                'description': e['descrizione'] ?? '',
              },
            )
            .toList();

    final languages =
        _languages
            .map(
              (e) => {
                'language': e['lingua'] ?? '',
                'level': e['livello'] ?? '',
              },
            )
            .toList();

    return {
      'personalInfo': personalInfo,
      'education': education,
      'experience': experience,
      'languages': languages,
      'skills': _skills,
      'jobGoal': {
        'position': _obiettivoController.text.trim(),
        'country': _paeseLavoroController.text.trim(),
        'availability': _disponibilitaController.text.trim(),
        'industry': _settoreController.text.trim(),
      },
      'config': {
        'template': _normalizedTemplateId(_cvModel),
        'templateId': _normalizedTemplateId(_cvModel),
        if ((selectedTemplate['cssUrl']?.toString().isNotEmpty ?? false))
          'templateCssUrl': selectedTemplate['cssUrl'],
        if ((selectedTemplate['htmlUrl']?.toString().isNotEmpty ?? false))
          'templateHtmlUrl': selectedTemplate['htmlUrl'],
        'cvLanguage': _normalizedCvLanguage(_cvLanguage),
        'includePhoto': _includePhoto,
      },
    };
  }

  Map<String, dynamic> _payloadDebugInsights(Map<String, dynamic> payload) {
    final personalInfo = payload['personalInfo'] as Map<String, dynamic>? ?? {};
    final firstName = personalInfo['firstName']?.toString().trim() ?? '';
    final lastName = personalInfo['lastName']?.toString().trim() ?? '';
    final email = personalInfo['email']?.toString().trim() ?? '';
    final experience = payload['experience'] as List<dynamic>? ?? [];
    final education = payload['education'] as List<dynamic>? ?? [];
    final photoBase64 = personalInfo['photoBase64']?.toString() ?? '';
    final photoAlias = personalInfo['photo']?.toString() ?? '';

    final missingRequired = <String>[
      if (firstName.isEmpty) 'personalInfo.firstName',
      if (lastName.isEmpty) 'personalInfo.lastName',
      if (email.isEmpty) 'personalInfo.email',
      if (experience.isEmpty && education.isEmpty)
        'experience|education(min 1)',
    ];

    return {
      'missingRequiredCount': missingRequired.length,
      'missingRequiredFields': missingRequired,
      'isMinPayloadValid': missingRequired.isEmpty,
      'hasBirthDate': personalInfo['birthDate'] != null,
      'hasAddress':
          (personalInfo['address']?.toString().trim().isNotEmpty ?? false),
      'hasPhotoBase64': photoBase64.isNotEmpty,
      'photoBase64Chars': photoBase64.length,
      'hasPhotoAlias': photoAlias.isNotEmpty,
    };
  }

  List<String> _extractValidationFieldIssues(dynamic fields) {
    if (fields is Map<String, dynamic>) {
      final issues = <String>[];
      fields.forEach((key, value) {
        final field = key.toString();
        final reason = value?.toString().trim() ?? '';
        issues.add(reason.isEmpty ? field : '$field: $reason');
      });
      return issues;
    }

    if (fields is List) {
      return fields
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return const [];
  }

  String _bodySnippet(dynamic body, {int maxChars = 300}) {
    final text = body is String ? body : jsonEncode(body);
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}...';
  }

  String _isoDateFromString(String date) {
    final parsed = _tryParseDate(date);
    if (parsed == null) return date;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  void _logCvGeneration(String event, {Map<String, dynamic>? data}) {
    final payload = {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    };
    debugPrint('[CV_AI] ${jsonEncode(payload)}');
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _setGeneratedFiles(Map<String, dynamic>? files) {
    _generatedPdfUrl = files?['pdfUrl']?.toString();
    _generatedDocxUrl = files?['docxUrl']?.toString();
  }

  Future<bool> _pollCvStatusUntilReady(String cvId) async {
    final startedAt = DateTime.now();
    final statusUri = Uri.parse('$_cvApiBase/$cvId');
    var attempt = 0;

    while (DateTime.now().difference(startedAt) < _maxPollingDuration) {
      await Future.delayed(_pollInterval);
      attempt++;

      final headers = await _buildAuthHeaders();
      final statusResponse = await HttpClientService.get(
        statusUri,
        headers: headers,
      );
      final statusBody = HttpClientService.decodeJsonResponse(statusResponse);
      final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;

      _logCvGeneration(
        'cv_generate_poll_status',
        data: {
          'attempt': attempt,
          'elapsedMs': elapsedMs,
          'statusCode': statusResponse.statusCode,
          'cvId': cvId,
          'status':
              statusBody is Map<String, dynamic> ? statusBody['status'] : null,
          'requestId':
              statusBody is Map<String, dynamic>
                  ? statusBody['requestId']
                  : null,
        },
      );

      if (statusResponse.statusCode != 200 ||
          statusBody is! Map<String, dynamic>) {
        continue;
      }

      final ok = statusBody['ok'] == true;
      final status = statusBody['status']?.toString();
      if (!ok) continue;

      if (status == 'generated') {
        setState(() {
          _generatedCvId = statusBody['cvId']?.toString() ?? cvId;
          _setGeneratedFiles(statusBody['files'] as Map<String, dynamic>?);
          _isGenerated = true;
        });
        return true;
      }

      if (status == 'failed') {
        _logCvGeneration(
          'cv_generate_poll_failed_status',
          data: {'attempt': attempt, 'elapsedMs': elapsedMs, 'cvId': cvId},
        );
        return false;
      }
    }

    return false;
  }

  Future<void> _openFileUrl(String? url, String actionLabel) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$actionLabel: file non disponibile')),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$actionLabel: URL non valido')));
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$actionLabel: impossibile aprire il file')),
      );
    }
  }

  Future<void> _generateCv() async {
    final startedAt = DateTime.now();
    _logCvGeneration('cv_generate_started', data: _cvGenerationSummary());

    await _saveDraft();

    setState(() {
      _isGenerating = true;
      _isGenerated = false;
      _generatedCvId = null;
      _generatedPdfUrl = null;
      _generatedDocxUrl = null;
    });

    try {
      final payload = await _buildCvGeneratePayload();
      final payloadDebug = _payloadDebugInsights(payload);
      final payloadJson = jsonEncode(payload);
      final headers = await _buildAuthHeaders();
      final uri = Uri.parse('$_cvApiBase/generate');

      _logCvGeneration(
        'cv_generate_request_sent',
        data: {
          'endpoint': uri.toString(),
          'hasAuth': headers['Authorization'] != null,
          'authPrefix':
              headers['Authorization'] != null ? 'Bearer ***' : 'none',
          'payloadBytes': utf8.encode(payloadJson).length,
          ...payloadDebug,
          'payloadSummary': _cvGenerationSummary(),
        },
      );

      if (utf8.encode(payloadJson).length > _maxBackendPayloadBytes) {
        _logCvGeneration(
          'cv_generate_payload_size_warning',
          data: {
            'payloadBytes': utf8.encode(payloadJson).length,
            'maxAllowedBytes': _maxBackendPayloadBytes,
          },
        );
      }

      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: payloadJson,
      );

      final body = HttpClientService.decodeJsonResponse(response);
      _logCvGeneration(
        'cv_generate_response_received',
        data: {
          'statusCode': response.statusCode,
          'contentType': response.headers['content-type'],
          'responseBytes': response.bodyBytes.length,
          'ok': body is Map<String, dynamic> ? body['ok'] : null,
          'status': body is Map<String, dynamic> ? body['status'] : null,
          'requestId': body is Map<String, dynamic> ? body['requestId'] : null,
          'errorCode':
              body is Map<String, dynamic>
                  ? (body['error'] is Map<String, dynamic>
                      ? (body['error'] as Map<String, dynamic>)['code']
                      : null)
                  : null,
          'message':
              body is Map<String, dynamic>
                  ? (body['error'] is Map<String, dynamic>
                      ? (body['error'] as Map<String, dynamic>)['message']
                      : body['message'])
                  : null,
        },
      );

      if (response.statusCode == 200 &&
          body is Map<String, dynamic> &&
          body['ok'] == true) {
        final cvId = body['cvId']?.toString();
        final status = body['status']?.toString();

        setState(() {
          _generatedCvId = cvId;
          _setGeneratedFiles(body['files'] as Map<String, dynamic>?);
          _isGenerated = status == 'generated';
        });

        if (cvId != null && status == 'processing') {
          final ready = await _pollCvStatusUntilReady(cvId);
          if (!ready && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'CV in elaborazione. Riprova tra qualche secondo.',
                ),
              ),
            );
          }
        }

        if (cvId != null && status == 'generated' && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CV generato con successo.')),
          );
        }
      } else if (response.statusCode == 422 && body is Map<String, dynamic>) {
        final error = body['error'] as Map<String, dynamic>?;
        final message = error?['message']?.toString() ?? 'Dati non validi';
        final requestId = body['requestId']?.toString();
        final validationIssues = _extractValidationFieldIssues(
          error?['fields'],
        );
        final tooLarge = validationIssues.any(
          (e) => e.toLowerCase().contains('payload exceeds 300kb'),
        );
        _logCvGeneration(
          'cv_generate_validation_error_details',
          data: {
            'requestId': requestId,
            'validationIssueCount': validationIssues.length,
            'validationIssues': validationIssues,
            'localMissingRequired': payloadDebug['missingRequiredFields'],
          },
        );

        final fieldsText =
            validationIssues.isEmpty
                ? ''
                : ' | Campi: ${validationIssues.take(4).join(' ; ')}';
        final requestText =
            (requestId != null && requestId.isNotEmpty)
                ? ' (requestId: $requestId)'
                : '';
        final sizeHint =
            tooLarge
                ? ' | Riduci la foto (ritaglio o risoluzione) e riprova.'
                : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore validazione: $message$fieldsText$requestText$sizeHint',
            ),
          ),
        );
      } else {
        final requestId =
            body is Map<String, dynamic> ? body['requestId']?.toString() : null;
        final errorCode =
            body is Map<String, dynamic>
                ? (body['error'] is Map<String, dynamic>
                    ? (body['error'] as Map<String, dynamic>)['code']
                        ?.toString()
                    : null)
                : null;
        final message =
            body is Map<String, dynamic>
                ? (body['message']?.toString() ??
                    'Errore durante la generazione del CV')
                : 'Errore durante la generazione del CV';
        final supportHint = [
          if (errorCode != null && errorCode.isNotEmpty) 'code: $errorCode',
          if (requestId != null && requestId.isNotEmpty)
            'requestId: $requestId',
        ].join(' | ');
        _logCvGeneration(
          'cv_generate_non_200_details',
          data: {
            'statusCode': response.statusCode,
            'requestId': requestId,
            'errorCode': errorCode,
            'bodySnippet': _bodySnippet(body),
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              supportHint.isEmpty ? message : '$message ($supportHint)',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      _logCvGeneration(
        'cv_generate_failed',
        data: {
          'error': error.toString(),
          'stackTraceSnippet': _bodySnippet(
            stackTrace.toString(),
            maxChars: 500,
          ),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Generazione fallita: $error')));
      }
    }

    if (!mounted) {
      _logCvGeneration('cv_generate_cancelled_unmounted');
      return;
    }

    final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    setState(() {
      _isGenerating = false;
      _isGenerated = _generatedPdfUrl != null || _generatedDocxUrl != null;
    });
    _logCvGeneration(
      'cv_generate_completed',
      data: {
        'durationMs': durationMs,
        'cvId': _generatedCvId,
        'hasPdf': _generatedPdfUrl != null,
        'hasDocx': _generatedDocxUrl != null,
        ..._cvGenerationSummary(),
      },
    );
  }

  void _nextStep() async {
    await _saveDraft();

    if (_currentStep < _totalSteps - 1) {
      final nextStep = _currentStep + 1;
      setState(() {
        _currentStep = nextStep;
      });
      if (nextStep == 6) {
        _loadTemplatePreview();
      }
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.translate('cvAiDraftSaved'),
        ),
      ),
    );
  }

  void _prevStep() {
    if (_currentStep == 0) return;
    setState(() {
      _currentStep--;
    });
  }

  void _addEducation() {
    if (_eduTitoloController.text.trim().isEmpty ||
        _eduIstitutoController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _educations.add({
        'titolo': _eduTitoloController.text.trim(),
        'istituto': _eduIstitutoController.text.trim(),
        'paese': _eduPaeseController.text.trim(),
        'inizio': _eduDataInizioController.text.trim(),
        'fine': _eduDataFineController.text.trim(),
        'descrizione': _eduDescrizioneController.text.trim(),
      });
      _eduTitoloController.clear();
      _eduIstitutoController.clear();
      _eduPaeseController.clear();
      _eduDataInizioController.clear();
      _eduDataFineController.clear();
      _eduDescrizioneController.clear();
    });
    _saveDraft();
  }

  void _addExperience() {
    if (_expRuoloController.text.trim().isEmpty ||
        _expAziendaController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _experiences.add({
        'ruolo': _expRuoloController.text.trim(),
        'azienda': _expAziendaController.text.trim(),
        'paese': _expPaeseController.text.trim(),
        'inizio': _expDataInizioController.text.trim(),
        'fine': _expDataFineController.text.trim(),
        'descrizione': _expDescrizioneController.text.trim(),
      });
      _expRuoloController.clear();
      _expAziendaController.clear();
      _expPaeseController.clear();
      _expDataInizioController.clear();
      _expDataFineController.clear();
      _expDescrizioneController.clear();
    });
    _saveDraft();
  }

  void _addLanguage() {
    final selectedLanguage = _normalizedSpokenLanguage(_selectedLanguage);
    final currentLevel = _normalizedLanguageLevel(_livelloLingua);

    setState(() {
      _languages.add({'lingua': selectedLanguage, 'livello': currentLevel});
      _livelloLingua = currentLevel;
      _selectedLanguage = selectedLanguage;
    });
    _saveDraft();
  }

  void _removeLanguageAt(int index) {
    if (index < 0 || index >= _languages.length) return;

    setState(() {
      _languages.removeAt(index);
    });
    _saveDraft();
  }

  void _addSkill() {
    final value = _skillController.text.trim();
    if (value.isEmpty) return;

    setState(() {
      _skills.add(value);
      _skillController.clear();
    });
    _saveDraft();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('cvAiServiceName'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: LinearProgressIndicator(value: progress),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('${_currentStep + 1}/$_totalSteps'),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(l10n),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _prevStep,
                      child: Text(l10n.back),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == _totalSteps - 1
                          ? l10n.complete
                          : l10n.next,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return _buildIntroStep(l10n);
      case 1:
        return _buildPersonalStep(l10n);
      case 2:
        return _buildEducationStep(l10n);
      case 3:
        return _buildExperienceStep(l10n);
      case 4:
        return _buildSkillsStep(l10n);
      case 5:
        return _buildObjectiveAndGenerationStep(l10n);
      case 6:
        return _buildTemplateStep(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap:
          () => _pickDateForController(
            controller,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed:
              () => _pickDateForController(
                controller,
                firstDate: firstDate,
                lastDate: lastDate,
              ),
        ),
      ),
    );
  }

  Widget _buildIntroStep(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('cvAiServiceName'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.translate('cvAiServiceSubtitle')),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_outlined),
                const SizedBox(width: 8),
                Text(l10n.translate('cvAiEstimatedTime')),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.translate('cvAiEuropassDisclaimer'),
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cvAiPersonalStep'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cognomeController,
          decoration: const InputDecoration(labelText: 'Cognome'),
        ),
        const SizedBox(height: 10),
        _buildDateField(
          controller: _dataNascitaController,
          label: 'Data di nascita',
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nazionalitaController,
          decoration: const InputDecoration(labelText: 'Nazionalita'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _indirizzoController,
          decoration: const InputDecoration(labelText: 'Indirizzo'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _telefonoController,
          decoration: const InputDecoration(labelText: 'Telefono'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showPhotoSourcePicker,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Carica o scatta foto CV'),
        ),
        const SizedBox(height: 6),
        const Text(
          'Consiglio: usa una foto frontale, ben illuminata e con sfondo neutro.',
          style: TextStyle(color: Colors.grey),
        ),
        if (_photoPath != null) ...[
          const SizedBox(height: 8),
          Text('Foto selezionata: ${_photoPath!.split('/').last}'),
        ],
      ],
    );
  }

  Widget _buildEducationStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cvAiEducationStep'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _eduTitoloController,
          decoration: const InputDecoration(labelText: 'Titolo di studio'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _eduIstitutoController,
          decoration: const InputDecoration(labelText: 'Istituto'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _eduPaeseController,
          decoration: const InputDecoration(labelText: 'Paese'),
        ),
        const SizedBox(height: 10),
        _buildDateField(
          controller: _eduDataInizioController,
          label: 'Data inizio',
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        ),
        const SizedBox(height: 10),
        _buildDateField(
          controller: _eduDataFineController,
          label: 'Data fine',
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _eduDescrizioneController,
          decoration: const InputDecoration(
            labelText: 'Descrizione (opzionale)',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _addEducation,
          icon: const Icon(Icons.add),
          label: Text(l10n.translate('cvAiAddItem')),
        ),
        const SizedBox(height: 12),
        _buildSimpleList(
          items:
              _educations
                  .map((e) => '${e['titolo']} - ${e['istituto']}')
                  .toList(),
          emptyLabel: l10n.translate('cvAiNoEntries'),
        ),
      ],
    );
  }

  Widget _buildExperienceStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cvAiExperienceStep'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _expRuoloController,
          decoration: const InputDecoration(labelText: 'Ruolo'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _expAziendaController,
          decoration: const InputDecoration(labelText: 'Azienda'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _expPaeseController,
          decoration: const InputDecoration(labelText: 'Paese'),
        ),
        const SizedBox(height: 10),
        _buildDateField(
          controller: _expDataInizioController,
          label: 'Data inizio',
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        ),
        const SizedBox(height: 10),
        _buildDateField(
          controller: _expDataFineController,
          label: 'Data fine',
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _expDescrizioneController,
          decoration: const InputDecoration(
            labelText: 'Descrizione attivita svolte',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _addExperience,
          icon: const Icon(Icons.add),
          label: Text(l10n.translate('cvAiAddItem')),
        ),
        const SizedBox(height: 12),
        _buildSimpleList(
          items:
              _experiences
                  .map((e) => '${e['ruolo']} - ${e['azienda']}')
                  .toList(),
          emptyLabel: l10n.translate('cvAiNoEntries'),
        ),
      ],
    );
  }

  Widget _buildSkillsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cvAiSkillsStep'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _normalizedSpokenLanguage(_selectedLanguage),
          items:
              _spokenLanguageOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedLanguage = value;
            });
          },
          decoration: const InputDecoration(labelText: 'Lingua'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _normalizedLanguageLevel(_livelloLingua),
          items:
              _languageLevelOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _livelloLingua = value;
            });
            _saveDraft();
          },
          decoration: const InputDecoration(labelText: 'Livello lingua'),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _addLanguage,
          icon: const Icon(Icons.add),
          label: Text(l10n.translate('cvAiAddItem')),
        ),
        const SizedBox(height: 10),
        _buildLanguageList(emptyLabel: l10n.translate('cvAiNoEntries')),
        const SizedBox(height: 14),
        TextField(
          controller: _skillController,
          decoration: const InputDecoration(
            labelText: 'Competenza (digitale/tecnica/relazionale)',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _addSkill,
          icon: const Icon(Icons.add),
          label: Text(l10n.translate('cvAiAddItem')),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _skills.map((e) => Chip(label: Text(e))).toList(),
        ),
      ],
    );
  }

  Widget _buildTemplateStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scegli template CV',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seleziona un template e visualizza anteprima con dati reali.',
        ),
        const SizedBox(height: 12),
        if (_isLoadingTemplates)
          const Center(child: CircularProgressIndicator())
        else if (_templatesError != null) ...[
          Text(_templatesError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadCvTemplates,
            icon: const Icon(Icons.refresh),
            label: const Text('Riprova caricamento template'),
          ),
        ] else if (_cvTemplates.isEmpty)
          const Text('Nessun template disponibile al momento.')
        else
          Column(
            children:
                _cvTemplates.map((template) {
                  final id = template['id']?.toString() ?? '';
                  final name = template['name']?.toString() ?? id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: id,
                            groupValue: _normalizedTemplateId(_cvModel),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _cvModel = value;
                              });
                              _saveDraft();
                              _loadTemplatePreview();
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'ID: $id',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                _isLoadingTemplatePreview
                                    ? null
                                    : _loadTemplatePreview,
                            icon: const Icon(Icons.preview_outlined),
                            label: const Text('Aggiorna anteprima'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        const SizedBox(height: 10),
        if (_isLoadingTemplatePreview)
          const Center(child: CircularProgressIndicator())
        else if (_templatePreviewError != null)
          Text(
            _templatePreviewError!,
            style: const TextStyle(color: Colors.red),
          )
        else if (_templatePreviewHtml != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: WebViewWidget(controller: _templatePreviewController),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _openTemplatePreviewModal,
                icon: const Icon(Icons.open_in_full),
                label: const Text('Apri anteprima grande'),
              ),
            ],
          ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _normalizedCvLanguage(_cvLanguage),
          items: const [
            DropdownMenuItem(value: 'it', child: Text('Italiano')),
            DropdownMenuItem(value: 'es', child: Text('Espanol')),
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'fr', child: Text('Francais')),
            DropdownMenuItem(value: 'de', child: Text('Deutsch')),
            DropdownMenuItem(value: 'pt', child: Text('Portugues')),
            DropdownMenuItem(value: 'nl', child: Text('Nederlands')),
            DropdownMenuItem(value: 'pl', child: Text('Polski')),
            DropdownMenuItem(value: 'ro', child: Text('Romana')),
            DropdownMenuItem(value: 'uk', child: Text('Ukrainska')),
            DropdownMenuItem(value: 'ru', child: Text('Russkiy')),
            DropdownMenuItem(value: 'el', child: Text('Ellinika')),
            DropdownMenuItem(value: 'sv', child: Text('Svenska')),
            DropdownMenuItem(value: 'cs', child: Text('Cesky')),
            DropdownMenuItem(value: 'hu', child: Text('Magyar')),
            DropdownMenuItem(value: 'tr', child: Text('Turkce')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _cvLanguage = _normalizedCvLanguage(value);
            });
            _saveDraft();
          },
          decoration: const InputDecoration(labelText: 'Lingua CV'),
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.translate('cvAiWithPhoto')),
          value: _includePhoto,
          onChanged: (value) {
            setState(() {
              _includePhoto = value;
            });
            _saveDraft();
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed:
              _isGenerating
                  ? null
                  : () {
                    if (_normalizedTemplateId(_cvModel).isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Seleziona un template prima di generare',
                          ),
                        ),
                      );
                      return;
                    }
                    _logCvGeneration(
                      'cv_generate_clicked',
                      data: _cvGenerationSummary(),
                    );
                    _generateCv();
                  },
          icon: const Icon(Icons.auto_awesome),
          label: Text(
            _isGenerating
                ? l10n.translate('cvAiGenerating')
                : l10n.translate('cvAiGenerate'),
          ),
        ),
        if (_isGenerated) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Text(l10n.translate('cvAiGenerated')),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    _generatedPdfUrl == null
                        ? null
                        : () => _openFileUrl(
                          _generatedPdfUrl,
                          l10n.translate('cvAiDownloadPdf'),
                        ),
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(l10n.translate('cvAiDownloadPdf')),
              ),
              OutlinedButton.icon(
                onPressed:
                    _generatedDocxUrl == null
                        ? null
                        : () => _openFileUrl(
                          _generatedDocxUrl,
                          l10n.translate('cvAiDownloadWord'),
                        ),
                icon: const Icon(Icons.description_outlined),
                label: Text(l10n.translate('cvAiDownloadWord')),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildObjectiveAndGenerationStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cvAiObjectiveStep'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _obiettivoController,
          decoration: const InputDecoration(
            labelText: 'Che lavoro stai cercando?',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _paeseLavoroController,
          decoration: const InputDecoration(labelText: 'In quale paese?'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _disponibilitaController,
          decoration: const InputDecoration(
            labelText: 'Disponibilita (full time, part time, turni...)',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _settoreController,
          decoration: const InputDecoration(labelText: 'Settore lavorativo'),
        ),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _vuoleFormazione,
          title: const Text('Vuoi fare formazione?'),
          onChanged: (value) {
            setState(() {
              _vuoleFormazione = value;
            });
            _saveDraft();
          },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _pickDocuments,
          icon: const Icon(Icons.upload_file),
          label: Text(l10n.translate('cvAiUploadSupportDocs')),
        ),
        const SizedBox(height: 8),
        _buildSimpleList(
          items:
              _documents
                  .map((e) => e['name'] ?? '')
                  .where((e) => e.isNotEmpty)
                  .toList(),
          emptyLabel: l10n.translate('cvAiNoEntries'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSimpleList({
    required List<String> items,
    required String emptyLabel,
  }) {
    if (items.isEmpty) {
      return Text(emptyLabel, style: const TextStyle(color: Colors.grey));
    }

    return Column(
      children:
          items
              .map(
                (e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline, size: 18),
                  title: Text(e),
                ),
              )
              .toList(),
    );
  }

  Widget _buildLanguageList({required String emptyLabel}) {
    if (_languages.isEmpty) {
      return Text(emptyLabel, style: const TextStyle(color: Colors.grey));
    }

    return Column(
      children: List.generate(_languages.length, (index) {
        final entry = _languages[index];
        final label = '${entry['lingua'] ?? ''} (${entry['livello'] ?? ''})';
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.check_circle_outline, size: 18),
          title: Text(label),
          trailing: IconButton(
            tooltip: 'Elimina',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeLanguageAt(index),
          ),
        );
      }),
    );
  }
}

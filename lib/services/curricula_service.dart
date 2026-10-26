import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:wecoop_app/utils/app_logger.dart';

import '../config/api_config.dart';
import '../models/curriculum_cv.dart';
import 'http_client_service.dart';
import 'secure_storage_service.dart';

class CvRisultato<T> {
  final T? data;
  final String? errore;
  final String? codice;
  final List<String> problemi;
  final bool offline;

  const CvRisultato.ok(this.data)
      : errore = null,
        codice = null,
        problemi = const [],
        offline = false;

  const CvRisultato.ko(
    this.errore, {
    this.codice,
    this.problemi = const [],
    this.offline = false,
  }) : data = null;

  bool get ok => errore == null;
  bool get moduloDisattivato => codice == 'CV_MODULE_DISABLED';
}

class CvElenco {
  final List<CurriculumCv> curricula;
  final List<CurriculumStorico> storico;

  const CvElenco(this.curricula, this.storico);
}

class CvPdfGenerato {
  final CurriculumCv cv;
  final int versione;
  final List<String> avvisi;

  const CvPdfGenerato(this.cv, this.versione, this.avvisi);
}

/// Client del Generatore CV V1.0 (`/api/curricula`).
class CurriculaService {
  static const String _base = '${ApiConfig.baseUrl}/curricula';
  static final SecureStorageService _storage = SecureStorageService();

  /// Cache letta da «Attiva supporto lavoro» e dalla pubblicazione annunci
  /// per sapere se l'utente ha un CV generato: va tenuta allineata.
  static const String legacyCacheKey = 'cv_ai_local_cvs_v1';

  /// Bozza locale del vecchio wizard: mai cancellata, solo importabile.
  static const String legacyDraftKey = 'cv_ai_draft_v1';
  static const String legacyDraftImportedKey = 'cv_ai_draft_v1_importata';

  static const String _sourceTag = 'curricula_v1';
  static const String _messaggioOffline =
      'Connessione assente. Controlla la rete e riprova.';
  static const String _messaggioGenerico =
      'Si è verificato un errore. Riprova tra qualche istante.';

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept-Language': 'it',
      };

  static Future<CvRisultato<T>> _call<T>(
    Future<dynamic> Function() request,
    T Function(Map<String, dynamic> body) parse,
  ) async {
    try {
      final response = await request();
      final status = response.statusCode as int;
      Map<String, dynamic> body = const {};
      try {
        final decoded = HttpClientService.decodeJsonResponse(response);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {}
      if (status >= 200 && status < 300 && body['ok'] == true) {
        return CvRisultato.ok(parse(body));
      }
      final err = body['error'] is Map ? Map<String, dynamic>.from(body['error']) : {};
      final problemi = (err['problemi'] as List?)
              ?.whereType<Map>()
              .map((p) => (p['messaggio'] ?? '').toString())
              .where((m) => m.isNotEmpty)
              .toList() ??
          const <String>[];
      return CvRisultato.ko(
        (err['message'] ?? body['message'] ?? _messaggioGenerico).toString(),
        codice: err['code']?.toString(),
        problemi: problemi,
      );
    } catch (e) {
      AppLogger.d('[CURRICULA] request failed: ${e.runtimeType}');
      final offline = HttpClientService.isTransientNetworkError(e);
      return CvRisultato.ko(
        offline ? _messaggioOffline : _messaggioGenerico,
        offline: offline,
      );
    }
  }

  static CurriculumCv _cv(Map<String, dynamic> body) =>
      CurriculumCv.fromJson(Map<String, dynamic>.from(body['cv'] as Map));

  static Future<CvRisultato<CvElenco>> elenco() async {
    final res = await _call(
      () => HttpClientService.get(Uri.parse(_base), headers: _jsonHeaders),
      (b) => CvElenco(
        ((b['curricula'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CurriculumCv.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        ((b['storico'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CurriculumStorico.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      ),
    );
    if (res.ok) await sincronizzaCacheCompatibilita(res.data!.curricula);
    return res;
  }

  static Future<CvRisultato<Map<String, String>>> prefill() => _call(
        () => HttpClientService.get(Uri.parse('$_base/prefill'), headers: _jsonHeaders),
        (b) => Map<String, dynamic>.from(b['personali'] as Map? ?? {})
            .map((k, v) => MapEntry(k, (v ?? '').toString())),
      );

  static Future<CvRisultato<CurriculumCv>> crea({
    String? titolo,
    CvDati? dati,
    Map<String, dynamic>? bozzaLegacy,
  }) =>
      _call(
        () => HttpClientService.post(
          Uri.parse(_base),
          headers: _jsonHeaders,
          body: jsonEncode({
            if (titolo != null) 'titolo': titolo,
            if (dati != null) 'dati': dati.toJson(),
            if (bozzaLegacy != null) 'bozzaLegacy': bozzaLegacy,
          }),
        ),
        _cv,
      );

  static Future<CvRisultato<CurriculumCv>> dettaglio(int id) => _call(
        () => HttpClientService.get(Uri.parse('$_base/$id'), headers: _jsonHeaders),
        _cv,
      );

  static Future<CvRisultato<CurriculumCv>> salva(
    int id, {
    CvDati? dati,
    String? titolo,
  }) async {
    final res = await _call(
      () => HttpClientService.put(
        Uri.parse('$_base/$id'),
        headers: _jsonHeaders,
        body: jsonEncode({
          if (dati != null) 'dati': dati.toJson(),
          if (titolo != null) 'titolo': titolo,
        }),
      ),
      _cv,
    );
    if (res.ok && dati != null) await eliminaBackupLocale(id);
    return res;
  }

  static Future<CvRisultato<CurriculumCv>> duplica(int id) => _call(
        () => HttpClientService.post(Uri.parse('$_base/$id/duplica'), headers: _jsonHeaders),
        _cv,
      );

  static Future<CvRisultato<bool>> elimina(int id) async {
    final res = await _call(
      () => HttpClientService.delete(Uri.parse('$_base/$id'), headers: _jsonHeaders),
      (_) => true,
    );
    if (res.ok) {
      await _rimuoviDaCache(id);
      await eliminaBackupLocale(id);
    }
    return res;
  }

  static Future<CvRisultato<CurriculumCv>> importaStorico(int legacyId) => _call(
        () => HttpClientService.post(
          Uri.parse('$_base/importa/$legacyId'),
          headers: _jsonHeaders,
        ),
        _cv,
      );

  static Future<CvRisultato<CurriculumCv>> caricaFoto(int id, List<int> jpegBytes) =>
      _call(
        () => HttpClientService.put(
          Uri.parse('$_base/$id/foto'),
          headers: _jsonHeaders,
          body: jsonEncode({'base64': base64Encode(jpegBytes)}),
        ),
        _cv,
      );

  static Future<CvRisultato<CurriculumCv>> rimuoviFoto(int id) => _call(
        () => HttpClientService.delete(Uri.parse('$_base/$id/foto'), headers: _jsonHeaders),
        _cv,
      );

  static Future<List<int>?> scaricaFoto(int id) async {
    try {
      final r = await HttpClientService.get(Uri.parse('$_base/$id/foto'), headers: _jsonHeaders);
      return r.statusCode == 200 ? r.bodyBytes : null;
    } catch (_) {
      return null;
    }
  }

  static Future<CvRisultato<CvPdfGenerato>> generaPdf(int id) async {
    final res = await _call(
      () => HttpClientService.post(Uri.parse('$_base/$id/pdf'), headers: _jsonHeaders),
      (b) => CvPdfGenerato(
        _cv(b),
        ((b['pdf'] as Map?)?['versione'] as num?)?.toInt() ?? 0,
        ((b['avvisi'] as List?) ?? const []).map((e) => e.toString()).toList(),
      ),
    );
    if (res.ok) await _aggiornaCache(res.data!.cv);
    return res;
  }

  static Future<CvRisultato<List<CvPdfInfo>>> versioni(int id) => _call(
        () => HttpClientService.get(Uri.parse('$_base/$id/pdf'), headers: _jsonHeaders),
        (b) => ((b['versioni'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => CvPdfInfo.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  /// Scarica il PDF (versione specifica o l'ultima) in un file locale dell'app.
  static Future<CvRisultato<File>> scaricaPdf(
    int id, {
    int? versione,
    required String nomeFile,
  }) =>
      _scaricaFile(
        Uri.parse('$_base/$id/pdf/${versione ?? 'ultima'}'),
        nomeFile,
      );

  static Future<CvRisultato<File>> scaricaPdfStorico(int legacyId, String nomeFile) =>
      _scaricaFile(Uri.parse('$_base/storico/$legacyId/pdf'), nomeFile);

  static Future<CvRisultato<File>> _scaricaFile(Uri uri, String nomeFile) async {
    try {
      final r = await HttpClientService.get(uri, headers: _jsonHeaders);
      final isPdf = (r.headers['content-type'] ?? '').contains('application/pdf');
      if (r.statusCode != 200 || !isPdf) {
        String msg = 'PDF non disponibile.';
        try {
          final body = HttpClientService.decodeJsonResponse(r);
          if (body is Map && body['error'] is Map) {
            msg = (body['error']['message'] ?? msg).toString();
          }
        } catch (_) {}
        return CvRisultato.ko(msg);
      }
      final dir = Directory('${(await getTemporaryDirectory()).path}/curricula');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final safe = nomeFile.replaceAll(RegExp(r'[^\w\-. ]'), '_');
      final file = File('${dir.path}/$safe');
      await file.writeAsBytes(r.bodyBytes, flush: true);
      return CvRisultato.ok(file);
    } catch (e) {
      final offline = HttpClientService.isTransientNetworkError(e);
      return CvRisultato.ko(
        offline ? _messaggioOffline : 'Download non riuscito. Riprova.',
        offline: offline,
      );
    }
  }

  // ---------------------------------------------------- backup locale bozza

  static String _backupKey(int id) => 'curricula_v1_backup_$id';

  /// Copia locale delle modifiche non ancora salvate sul server (rete assente).
  static Future<void> salvaBackupLocale(int id, CvDati dati) async {
    await _storage.write(
      key: _backupKey(id),
      value: jsonEncode({'at': DateTime.now().toIso8601String(), 'dati': dati.toJson()}),
    );
  }

  static Future<({DateTime at, CvDati dati})?> leggiBackupLocale(int id) async {
    final raw = await _storage.read(key: _backupKey(id));
    if (raw == null || raw.isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (
        at: DateTime.tryParse(j['at']?.toString() ?? '') ?? DateTime.now(),
        dati: CvDati.fromJson(Map<String, dynamic>.from(j['dati'] as Map)),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> eliminaBackupLocale(int id) => _storage.delete(key: _backupKey(id));

  // ------------------------------------------- bozza del vecchio generatore

  static Future<Map<String, dynamic>?> bozzaVecchioFlussoDaImportare() async {
    if ((await _storage.read(key: legacyDraftImportedKey)) == '1') return null;
    final raw = await _storage.read(key: legacyDraftKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final draft = Map<String, dynamic>.from(decoded);
      final hasContent = [
        draft['nome'],
        draft['cognome'],
        draft['email'],
        draft['obiettivo'],
      ].any((v) => (v ?? '').toString().trim().isNotEmpty) ||
          (draft['experiences'] is List && (draft['experiences'] as List).isNotEmpty) ||
          (draft['educations'] is List && (draft['educations'] as List).isNotEmpty);
      return hasContent ? draft : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> segnaBozzaVecchioFlussoGestita() =>
      _storage.write(key: legacyDraftImportedKey, value: '1');

  // ------------------------------------- compatibilità con moduli esistenti

  static Future<List<Map<String, dynamic>>> _leggiCache() async {
    try {
      final raw = await _storage.read(key: legacyCacheKey);
      if (raw == null || raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic> _voceCache(CurriculumCv cv) => {
        'cvId': 'curricula-${cv.id}',
        'source': _sourceTag,
        'status': 'generated',
        'firstName': cv.titolo,
        'files': {'pdfUrl': '$_base/${cv.id}/pdf/ultima', 'docxUrl': null},
        'createdAt': (cv.createdAt ?? DateTime.now()).toIso8601String(),
        'updatedAt': (cv.ultimoPdf?.createdAt ?? cv.updatedAt ?? DateTime.now())
            .toIso8601String(),
      };

  /// Riscrive in cache solo le voci del nuovo generatore; quelle del vecchio
  /// flusso restano intatte.
  static Future<void> sincronizzaCacheCompatibilita(List<CurriculumCv> curricula) async {
    final cache = await _leggiCache();
    cache.removeWhere((e) => e['source'] == _sourceTag);
    cache.addAll(curricula.where((c) => c.ultimoPdf != null).map(_voceCache));
    await _storage.write(key: legacyCacheKey, value: jsonEncode(cache));
  }

  static Future<void> _aggiornaCache(CurriculumCv cv) async {
    final cache = await _leggiCache();
    cache.removeWhere((e) => e['cvId'] == 'curricula-${cv.id}');
    cache.add(_voceCache(cv));
    await _storage.write(key: legacyCacheKey, value: jsonEncode(cache));
  }

  static Future<void> _rimuoviDaCache(int id) async {
    final cache = await _leggiCache();
    cache.removeWhere((e) => e['cvId'] == 'curricula-$id');
    await _storage.write(key: legacyCacheKey, value: jsonEncode(cache));
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/documento.dart';
import 'socio_service.dart';

class DocumentoService {
  static const String _documentiKey = 'documenti_utente';

  // Singleton
  static final DocumentoService _instance = DocumentoService._internal();
  factory DocumentoService() => _instance;
  DocumentoService._internal();

  // Cache locale
  List<Documento>? _documenti;

  // Ottiene tutti i documenti
  Future<List<Documento>> getDocumenti() async {
    if (_documenti != null) return _documenti!;

    final prefs = await SharedPreferences.getInstance();
    final String? documentiJson = prefs.getString(_documentiKey);

    if (documentiJson == null || documentiJson.isEmpty) {
      _documenti = [];
      return _documenti!;
    }

    final List<dynamic> documentiList = jsonDecode(documentiJson);
    _documenti = documentiList.map((json) => Documento.fromJson(json)).toList();
    return _documenti!;
  }

  // Salva i documenti
  Future<void> _saveDocumenti(List<Documento> documenti) async {
    final prefs = await SharedPreferences.getInstance();
    final String documentiJson = jsonEncode(
      documenti.map((doc) => doc.toJson()).toList(),
    );
    await prefs.setString(_documentiKey, documentiJson);
    _documenti = documenti;
  }

  // Ottiene un documento per tipo
  Documento? getDocumentoByTipo(String tipo) {
    if (_documenti == null) return null;
    try {
      return _documenti!.firstWhere((doc) => doc.tipo == tipo);
    } catch (e) {
      return null;
    }
  }

  // Verifica se un documento esiste
  bool hasDocumento(String tipo) {
    return getDocumentoByTipo(tipo) != null;
  }

  // Ottiene i documenti mancanti da una lista richiesta
  List<String> getDocumentiMancanti(List<String> tipiRichiesti) {
    return tipiRichiesti.where((tipo) => !hasDocumento(tipo)).toList();
  }

  // Verifica se ci sono documenti in scadenza (entro 30 giorni)
  Future<List<Documento>> getDocumentiInScadenza() async {
    final documenti = await getDocumenti();
    return documenti.where((doc) => doc.staPerScadere).toList();
  }

  // Verifica se ci sono documenti scaduti
  Future<List<Documento>> getDocumentiScaduti() async {
    final documenti = await getDocumenti();
    return documenti.where((doc) => doc.isScaduto).toList();
  }

  // Carica un nuovo documento da file
  Future<Documento?> caricaDocumento({
    required String tipo,
    DateTime? dataScadenza,
  }) async {
    // Seleziona il file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    return _salvaDocumento(
      file: file,
      fileName: fileName,
      tipo: tipo,
      dataScadenza: dataScadenza,
    );
  }

  // Cattura una singola immagine con la fotocamera (restituisce solo il File, senza salvare)
  Future<File?> prendiImmagineDaFotocamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (photo == null) return null;
    return File(photo.path);
  }

  // Seleziona una singola immagine dalla galleria (restituisce solo il File, senza salvare)
  Future<File?> prendiImmagineDaGalleria() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  // Carica un documento con FRONTE e RETRO (da fotocamera o galleria)
  Future<Documento?> caricaDocumentoDueLati({
    required String tipo,
    required File fileFrente,
    required File fileRetro,
  }) async {
    print('🔍 DEBUG: caricaDocumentoDueLati() tipo=$tipo');

    final appDir = await getApplicationDocumentsDirectory();
    final documentiDir = Directory('${appDir.path}/documenti');
    if (!await documentiDir.exists()) {
      await documentiDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final extFrente = _getFileExtension(fileFrente.path.split('/').last);
    final newFileNameFrente = '${tipo}_fronte_$timestamp$extFrente';
    final savedFrente = await fileFrente.copy('${documentiDir.path}/$newFileNameFrente');

    final extRetro = _getFileExtension(fileRetro.path.split('/').last);
    final newFileNameRetro = '${tipo}_retro_$timestamp$extRetro';
    final savedRetro = await fileRetro.copy('${documentiDir.path}/$newFileNameRetro');

    try {
      // Upload fronte
      print('📤 Upload fronte...');
      final uploadFrente = await SocioService.uploadDocumento(
        file: savedFrente,
        tipoDocumento: '${tipo}_fronte',
      );
      if (uploadFrente['success'] != true) {
        print('❌ Errore upload fronte: ${uploadFrente['message']}');
        await savedFrente.delete();
        await savedRetro.delete();
        return null;
      }

      // Upload retro
      print('📤 Upload retro...');
      final uploadRetro = await SocioService.uploadDocumento(
        file: savedRetro,
        tipoDocumento: '${tipo}_retro',
      );
      if (uploadRetro['success'] != true) {
        print('❌ Errore upload retro: ${uploadRetro['message']}');
        await savedFrente.delete();
        await savedRetro.delete();
        return null;
      }

      print('✅ Fronte e retro caricati!');

      final backendId = uploadFrente['data']?['id'];
      final documento = Documento(
        id: backendId?.toString() ?? timestamp.toString(),
        tipo: tipo,
        filePath: savedFrente.path,
        fileName: newFileNameFrente,
        filePathRetro: savedRetro.path,
        fileNameRetro: newFileNameRetro,
        dataCaricamento: DateTime.now(),
      );

      await rimuoviDocumentoByTipo(tipo);
      final documenti = await getDocumenti();
      documenti.add(documento);
      await _saveDocumenti(documenti);

      return documento;
    } catch (e) {
      print('❌ Eccezione caricaDocumentoDueLati: $e');
      if (await savedFrente.exists()) await savedFrente.delete();
      if (await savedRetro.exists()) await savedRetro.delete();
      return null;
    }
  }

  // Carica un nuovo documento con la fotocamera (lato singolo, usato come fallback)
  Future<Documento?> caricaDocumentoDaFotocamera({
    required String tipo,
    DateTime? dataScadenza,
  }) async {
    final file = await prendiImmagineDaFotocamera();
    if (file == null) return null;
    final fileName = '${tipo}_foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return _salvaDocumento(
      file: file,
      fileName: fileName,
      tipo: tipo,
      dataScadenza: dataScadenza,
    );
  }

  // Carica un nuovo documento dalla galleria (lato singolo, usato come fallback)
  Future<Documento?> caricaDocumentoDaGalleria({
    required String tipo,
    DateTime? dataScadenza,
  }) async {
    final file = await prendiImmagineDaGalleria();
    if (file == null) return null;
    final fileName = file.path.split('/').last;
    return _salvaDocumento(
      file: file,
      fileName: fileName,
      tipo: tipo,
      dataScadenza: dataScadenza,
    );
  }

  // Metodo privato per salvare il documento (usato da entrambi i metodi)
  Future<Documento?> _salvaDocumento({
    required File file,
    required String fileName,
    required String tipo,
    DateTime? dataScadenza,
  }) async {
    print('🔍 DEBUG: Inizio _salvaDocumento()');
    print('   Tipo: $tipo');
    print('   FileName: $fileName');
    
    // 1. Copia il file nella directory dell'app (per cache locale)
    final appDir = await getApplicationDocumentsDirectory();
    final documentiDir = Directory('${appDir.path}/documenti');
    if (!await documentiDir.exists()) {
      await documentiDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFileName = '${tipo}_$timestamp${_getFileExtension(fileName)}';
    final newPath = '${documentiDir.path}/$newFileName';
    final savedFile = await file.copy(newPath);

    // 2. ✅ INVIA AL BACKEND
    print('📤 Invio documento al backend...');
    try {
      final uploadResult = await SocioService.uploadDocumento(
        file: savedFile,
        tipoDocumento: tipo,
      );
      print('📥 Upload result: $uploadResult');

      if (uploadResult['success'] != true) {
        print('❌ Errore upload backend: ${uploadResult['message']}');
        // Rimuovi file locale se upload fallisce
        await savedFile.delete();
        return null;
      }

      print('✅ Documento caricato sul backend!');
      
      // 3. Crea documento locale con ID dal backend
      final backendId = uploadResult['data']?['id'];
      final documento = Documento(
        id: backendId?.toString() ?? timestamp.toString(),
        tipo: tipo,
        filePath: savedFile.path,
        fileName: fileName,
        dataCaricamento: DateTime.now(),
        dataScadenza: dataScadenza,
      );

      // 4. Rimuove il documento precedente dello stesso tipo se esiste
      await rimuoviDocumentoByTipo(tipo);

      // 5. Salva il nuovo documento
      final documenti = await getDocumenti();
      documenti.add(documento);
      await _saveDocumenti(documenti);

      return documento;
    } catch (e) {
      print('❌ Eccezione durante upload: $e');
      // Rimuovi file locale se upload fallisce
      await savedFile.delete();
      return null;
    }
  }

  // Aggiorna un documento esistente
  Future<bool> aggiornaDocumento({
    required String tipo,
    DateTime? dataScadenza,
  }) async {
    final nuovoDoc = await caricaDocumento(
      tipo: tipo,
      dataScadenza: dataScadenza,
    );
    return nuovoDoc != null;
  }

  // Rimuove un documento per tipo
  Future<void> rimuoviDocumentoByTipo(String tipo) async {
    final documenti = await getDocumenti();
    final docDaRimuovere = documenti.where((doc) => doc.tipo == tipo).toList();

    for (var doc in docDaRimuovere) {
      // Elimina il file fisico
      final file = File(doc.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      // Rimuove dalla lista
      documenti.remove(doc);
    }

    await _saveDocumenti(documenti);
  }

  // Rimuove un documento per ID
  Future<void> rimuoviDocumento(String id) async {
    final documenti = await getDocumenti();
    final doc = documenti.firstWhere((d) => d.id == id);

    // Elimina il file fisico
    final file = File(doc.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // Rimuove dalla lista
    documenti.removeWhere((d) => d.id == id);
    await _saveDocumenti(documenti);
  }

  // Helper per ottenere l'estensione del file
  String _getFileExtension(String fileName) {
    return fileName.substring(fileName.lastIndexOf('.'));
  }

  // Invalida la cache
  void invalidateCache() {
    _documenti = null;
  }
}

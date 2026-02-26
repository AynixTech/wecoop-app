import 'package:flutter/material.dart';
import '../models/firma_digitale_models.dart';
import './firma_digitale_service.dart';

// Enum per tracciare lo stadio del flusso di firma
enum FirmaStep {
  initial, // Nessuna azione
  loadingDocumento, // Caricamento documento
  documentoCaricato, // Documento pronto
  otpInviato, // SMS con OTP inviato
  verificaOTP, // In corso verifica OTP
  otpVerificato, // OTP verificato
  firmando, // In corso firma
  firmato, // Documento firmato con successo
  errore, // Errore durante il processo
}

class FirmaDigitaleProvider extends ChangeNotifier {
  // State
  FirmaStep _step = FirmaStep.initial;
  DocumentoUnico? _documento;
  OTPGenerateResponse? _otpGenerata;
  OTPVerifyResponse? _otpVerificata;
  FirmaDigitale? _firmaCreata;
  String? _errorMessage;
  String? _errorCode;
  int? _tentativiRimasti;

  // Parametri del flusso
  int? _richiestaId;
  int? _userId;
  String? _telefono;

  // Getter
  FirmaStep get step => _step;
  DocumentoUnico? get documento => _documento;
  OTPGenerateResponse? get otpGenerata => _otpGenerata;
  OTPVerifyResponse? get otpVerificata => _otpVerificata;
  FirmaDigitale? get firmaCreata => _firmaCreata;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  int? get tentativiRimasti => _tentativiRimasti;
  int? get richiestaId => _richiestaId;
  int? get userId => _userId;
  String? get telefono => _telefono;

  // Helper per controllare lo stato
  bool get isLoading =>
      _step == FirmaStep.loadingDocumento ||
      _step == FirmaStep.verificaOTP ||
      _step == FirmaStep.firmando;

  bool get isFirmato => _step == FirmaStep.firmato;

  bool get hasError => _step == FirmaStep.errore;

  // Inizializza il flusso di firma
  void iniziaFlusso({
    required int richiestaId,
    required int userId,
    required String telefono,
  }) {
    _richiestaId = richiestaId;
    _userId = userId;
    _telefono = telefono;
    _step = FirmaStep.initial;
    _errorMessage = null;
    _errorCode = null;
    _tentativiRimasti = null;
    printDebug('🔐 Inizializzato flusso firma richiestaId=$richiestaId userId=$userId telefonoPresente=${telefono.isNotEmpty}');
    notifyListeners();
  }

  // Step 1: Scarica il documento
  Future<void> scaricaDocumento() async {
    if (_richiestaId == null) {
      _setError('Richiesta ID non inizializzato', 'INVALID_STATE');
      return;
    }

    try {
      printDebug('📄 [Provider] scaricaDocumento start richiestaId=$_richiestaId');
      _step = FirmaStep.loadingDocumento;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();

      printDebug('📄 Scarico documento...');
      _documento = await FirmaDigitaleService.scaricaDocumento(_richiestaId!);

      _step = FirmaStep.documentoCaricato;
      printDebug('✅ Documento caricato nome=${_documento?.nome} url=${_documento?.url}');
      notifyListeners();
    } on FirmaDigitaleException catch (e) {
      printDebug('❌ [Provider] scaricaDocumento fail message=${e.message} code=${e.code}');
      _setError(e.message, e.code ?? 'UNKNOWN');
    } catch (e) {
      printDebug('❌ [Provider] scaricaDocumento eccezione inattesa=$e');
      _setError('Errore inaspettato: $e', 'UNKNOWN');
    }
  }

  // Step 2: Richiedi OTP
  Future<void> richiestaOTP() async {
    if (_richiestaId == null || _userId == null || _telefono == null) {
      printDebug('❌ [Provider] richiestaOTP parametri mancanti richiestaId=$_richiestaId userId=$_userId telefono=$_telefono');
      _setError('Parametri non inizializzati', 'INVALID_STATE');
      return;
    }

    try {
      printDebug('📱 [Provider] richiestaOTP start richiestaId=$_richiestaId telefono=$_telefono');
      _step = FirmaStep.loadingDocumento;
      notifyListeners();

      printDebug('📱 Genero OTP...');
      _otpGenerata = await FirmaDigitaleService.generaOTP(
        richiestaId: _richiestaId!,
        userId: _userId!,
        telefono: _telefono!,
      );

      _step = FirmaStep.otpInviato;
      printDebug('✅ OTP inviato via SMS+Email otpId=${_otpGenerata?.id} scadenza=${_otpGenerata?.scadenza} metodo=${_otpGenerata?.metodoInvio}');
      notifyListeners();
    } on FirmaDigitaleException catch (e) {
      printDebug('❌ [Provider] richiestaOTP fail message=${e.message} code=${e.code}');
      _setError(e.message, e.code ?? 'UNKNOWN');
    } catch (e) {
      printDebug('❌ [Provider] richiestaOTP eccezione inattesa=$e');
      _setError('Errore inaspettato: $e', 'UNKNOWN');
    }
  }

  // Step 3: Verifica OTP
  Future<void> verificaOTP(String codice) async {
    if (_otpGenerata?.id == null) {
      printDebug('❌ [Provider] verificaOTP otpId mancante');
      _setError('OTP ID non disponibile', 'INVALID_STATE');
      return;
    }

    if (codice.isEmpty) {
      printDebug('❌ [Provider] verificaOTP codice vuoto');
      _setError('Inserisci il codice OTP', 'EMPTY_CODE');
      return;
    }

    try {
      printDebug('✅ [Provider] verificaOTP start otpId=${_otpGenerata?.id} codeLength=${codice.length}');
      _step = FirmaStep.verificaOTP;
      notifyListeners();

      printDebug('✅ Verifico OTP...');
      _otpVerificata = await FirmaDigitaleService.verificaOTP(
        otpId: _otpGenerata!.id,
        otpCode: codice,
      );

      _step = FirmaStep.otpVerificato;
      printDebug('✅ OTP verificato id=${_otpVerificata?.id} verified=${_otpVerificata?.verified}');
      notifyListeners();
    } on FirmaDigitaleException catch (e) {
      _tentativiRimasti = e.tentativiRimasti;
      printDebug('❌ [Provider] verificaOTP fail message=${e.message} code=${e.code} tentativiRimasti=${e.tentativiRimasti}');
      _setError(e.message, e.code ?? 'INVALID_OTP');
    } catch (e) {
      printDebug('❌ [Provider] verificaOTP eccezione inattesa=$e');
      _setError('Errore inaspettato: $e', 'UNKNOWN');
    }
  }

  // Step 4: Firma il documento
  Future<void> firmaDocumento({
    required String deviceType,
    required String deviceModel,
    required String appVersion,
  }) async {
    if (_otpGenerata?.id == null ||
        _richiestaId == null ||
        _documento?.hashSha256 == null) {
      printDebug('❌ [Provider] firmaDocumento dati mancanti otpId=${_otpGenerata?.id} richiestaId=$_richiestaId hash=${_documento?.hashSha256 != null}');
      _setError('Dati necessari non disponibili', 'INVALID_STATE');
      return;
    }

    try {
      printDebug('🔐 [Provider] firmaDocumento start otpId=${_otpGenerata?.id} richiestaId=$_richiestaId');
      _step = FirmaStep.firmando;
      notifyListeners();

      printDebug('🔐 Firmo documento...');
      _firmaCreata = await FirmaDigitaleService.firmaDocumento(
        otpId: _otpGenerata!.id,
        richiestaId: _richiestaId!,
        documentoContenuto: _documento!.contenutoTesto,
        deviceType: deviceType,
        deviceModel: deviceModel,
        appVersion: appVersion,
      );

      _step = FirmaStep.firmato;
      printDebug('✅ Documento firmato id=${_firmaCreata?.id} status=${_firmaCreata?.status}');
      notifyListeners();
    } on FirmaDigitaleException catch (e) {
      if (e.code == 'document_already_signed') {
        final details = e.details ?? {};
        final firmaId = (details['firma_id'] ?? details['id'] ?? 'existing_signature').toString();
        final firmaTimestampRaw =
            details['firma_timestamp'] ?? details['data_firma'] ?? DateTime.now().toIso8601String();
        final metodo = (details['firma_tipo'] ?? details['metodo_firma'] ?? 'FES').toString();

        DateTime firmaTimestamp;
        if (firmaTimestampRaw is String) {
          firmaTimestamp = DateTime.tryParse(firmaTimestampRaw) ?? DateTime.now();
        } else {
          firmaTimestamp = DateTime.now();
        }

        _firmaCreata = FirmaDigitale(
          id: firmaId,
          richiestaId: _richiestaId!,
          firmaTimestamp: firmaTimestamp,
          metodoFirma: metodo,
          status: 'valida',
          hashVerificato: true,
        );
        _step = FirmaStep.firmato;
        _errorMessage = null;
        _errorCode = null;
        printDebug('⚠️ [Provider] Documento già firmato, tratto come firmato. firmaId=$firmaId timestamp=$firmaTimestamp');
        notifyListeners();
        return;
      }
      printDebug('❌ [Provider] firmaDocumento fail message=${e.message} code=${e.code}');
      _setError(e.message, e.code ?? 'UNKNOWN');
    } catch (e) {
      printDebug('❌ [Provider] firmaDocumento eccezione inattesa=$e');
      _setError('Errore inaspettato: $e', 'UNKNOWN');
    }
  }

  // Helper per settare errore
  void _setError(String message, String? code) {
    final prevStep = _step;
    _step = FirmaStep.errore;
    _errorMessage = message;
    _errorCode = code;
    printDebug('❌ Errore daStep=$prevStep aStep=$_step message=$message code=$code');
    notifyListeners();
  }

  // Reset dello stato
  void reset() {
    _step = FirmaStep.initial;
    _documento = null;
    _otpGenerata = null;
    _otpVerificata = null;
    _firmaCreata = null;
    _errorMessage = null;
    _errorCode = null;
    _tentativiRimasti = null;
    _richiestaId = null;
    _userId = null;
    _telefono = null;
    printDebug('🔄 Provider resettato');
    notifyListeners();
  }

  // Debug helper
  void printDebug(String message) {
    print('[FirmaDigitalProvider] $message');
  }
}

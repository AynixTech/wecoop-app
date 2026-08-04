import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import '../models/firma_digitale_models.dart';
import '../config/api_config.dart';
import 'dart:io';

class FirmaDigitaleService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final storage = SecureStorageService();

  /// Ottiene gli headers comuni per tutte le richieste
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    final languageCode = await storage.read(key: 'language_code') ?? 'it';
    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };

    if (includeAuth) {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// 1️⃣ Scarica il Documento Unico (PDF + Testo)
  /// POST /documento-unico/{richiesta_id}/send
  /// Response include: URL PDF, contenuto testo compilato, hash SHA-256, data generazione
  static Future<DocumentoUnico> scaricaDocumento(int richiestaId) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/documento-unico/$richiestaId/send';

      AppLogger.d('📄 Scarico documento da: $url');
      AppLogger.d(
        '📄 [DocFetch] richiestaId=$richiestaId hasAuthHeader=${headers.containsKey('Authorization')} lang=${headers['Accept-Language']}',
      );

      final response = await HttpClientService.post(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.d('Status code: ${response.statusCode}');
      AppLogger.d('📄 [DocFetch] content-type=${response.headers['content-type']}');
      AppLogger.d('📄 [DocFetch] body length=${response.body.length}');
      final bodyPreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      AppLogger.d('📄 [DocFetch] body preview: $bodyPreview');

      if (response.statusCode == 200) {
        // Verifica se la risposta contiene warning PHP
        if (response.body.trim().startsWith('<')) {
          AppLogger.d('❌ [DocFetch] Risposta HTML invece di JSON');
          throw FirmaDigitaleException(
            message: 'Il backend ha restituito HTML/warning PHP invece di JSON',
            code: 'INVALID_RESPONSE',
          );
        }

        final data = jsonDecode(response.body);
        AppLogger.d(
          '📄 [DocFetch] data keys=${data is Map<String, dynamic> ? data.keys.toList() : 'not-a-map'}',
        );

        if (data['success'] == true && data['documento'] != null) {
          final documento = data['documento'] as Map<String, dynamic>;
          AppLogger.d('✅ [DocFetch] documento keys=${documento.keys.toList()}');
          AppLogger.d('✅ [DocFetch] documento.url=${documento['url']}');
          AppLogger.d('✅ [DocFetch] documento.nome=${documento['nome']}');
          return DocumentoUnico.fromJson(data['documento']);
        } else {
          AppLogger.d(
            '❌ [DocFetch] success=${data['success']} error=${data['error']} code=${data['code']}',
          );
          throw FirmaDigitaleException(
            message:
                data['error'] ??
                'Errore sconosciuto nel download del documento',
            code: data['code'] ?? 'UNKNOWN',
          );
        }
      } else if (response.statusCode == 404) {
        AppLogger.d('❌ [DocFetch] 404 richiesta non trovata');
        AppLogger.d('❌ [DocFetch] body 404: ${response.body}');
        throw FirmaDigitaleException(
          message: 'Richiesta non trovata',
          code: 'NOT_FOUND',
        );
      } else if (response.statusCode == 401) {
        AppLogger.d('❌ [DocFetch] 401 autenticazione richiesta');
        AppLogger.d('❌ [DocFetch] body 401: ${response.body}');
        throw FirmaDigitaleException(
          message: 'Autenticazione richiesta',
          code: 'UNAUTHORIZED',
        );
      } else {
        AppLogger.d('❌ [DocFetch] status non gestito: ${response.statusCode}');
        AppLogger.d('❌ [DocFetch] body error: ${response.body}');
        throw FirmaDigitaleException(
          message: 'Errore download documento: ${response.statusCode}',
          code: 'SERVER_ERROR',
        );
      }
    } on SocketException catch (e) {
      AppLogger.d('❌ [DocFetch] SocketException: $e');
      throw FirmaDigitaleException(
        message: 'Errore di connessione: $e',
        code: 'CONNECTION_ERROR',
      );
    } on FirmaDigitaleException {
      rethrow;
    } catch (e) {
      AppLogger.d('❌ [DocFetch] Eccezione inattesa: $e');
      throw FirmaDigitaleException(
        message: 'Errore inaspettato: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// 2️⃣ Genera OTP per la firma
  /// POST /firma-digitale/otp/generate
  /// Invia OTP via SMS al numero custodito
  static Future<OTPGenerateResponse> generaOTP({
    required int richiestaId,
    required int userId,
    required String telefono,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/firma-digitale/otp/generate';
      final requestBody = {'richiesta_id': richiestaId, 'telefono': telefono};

      AppLogger.d('📱 Genero OTP per richiesta: $richiestaId');
      AppLogger.d('📱 [OtpGenerate] url=$url');
      AppLogger.d(
        '📱 [OtpGenerate] hasAuthHeader=${headers.containsKey('Authorization')}',
      );
      AppLogger.d('📱 [OtpGenerate] requestBody=$requestBody');

      final response = await HttpClientService.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      AppLogger.d('Status code: ${response.statusCode}');
      AppLogger.d(
        '📱 [OtpGenerate] content-type=${response.headers['content-type']}',
      );
      AppLogger.d('📱 [OtpGenerate] body length=${response.body.length}');
      final bodyPreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      AppLogger.d('📱 [OtpGenerate] body preview: $bodyPreview');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.d(
          '📱 [OtpGenerate] data keys=${data is Map<String, dynamic> ? data.keys.toList() : 'not-a-map'}',
        );
        AppLogger.d(
          '📱 [OtpGenerate] success=${data is Map<String, dynamic> ? data['success'] : null} error=${data is Map<String, dynamic> ? data['error'] : null} code=${data is Map<String, dynamic> ? data['code'] : null}',
        );

        if (data['success'] == true && data['otp'] != null) {
          AppLogger.d(
            '✅ [OtpGenerate] otp payload keys=${(data['otp'] as Map<String, dynamic>).keys.toList()}',
          );
          return OTPGenerateResponse.fromJson(data['otp']);
        } else if (data['success'] == true && data['otp_id'] != null) {
          final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 300;
          final scadenza = DateTime.now().add(Duration(seconds: expiresIn));
          final otpFallbackPayload = {
            'id': data['otp_id'].toString(),
            'scadenza': scadenza.toIso8601String(),
            'tentativi_rimasti': 3,
            'metodo_invio': 'sms',
          };
          AppLogger.d(
            '✅ [OtpGenerate] formato alternativo rilevato, payload normalizzato=$otpFallbackPayload',
          );
          return OTPGenerateResponse.fromJson(otpFallbackPayload);
        } else {
          throw FirmaDigitaleException(
            message: data['error'] ?? 'Errore nella generazione OTP',
            code: data['code'] ?? 'UNKNOWN',
          );
        }
      } else if (response.statusCode == 429) {
        // Rate limited
        AppLogger.d('❌ [OtpGenerate] 429 body=${response.body}');
        throw FirmaDigitaleException(
          message: 'Troppi tentativi. Riprova tra 1 ora',
          code: 'RATE_LIMITED',
        );
      } else if (response.statusCode == 401) {
        AppLogger.d('❌ [OtpGenerate] 401 body=${response.body}');
        throw FirmaDigitaleException(
          message: 'Autenticazione richiesta',
          code: 'UNAUTHORIZED',
        );
      } else {
        AppLogger.d(
          '❌ [OtpGenerate] status=${response.statusCode} body=${response.body}',
        );
        throw FirmaDigitaleException(
          message: 'Errore generazione OTP: ${response.statusCode}',
          code: 'SERVER_ERROR',
        );
      }
    } on SocketException catch (e) {
      AppLogger.d('❌ [OtpGenerate] SocketException: $e');
      throw FirmaDigitaleException(
        message: 'Errore di connessione: $e',
        code: 'CONNECTION_ERROR',
      );
    } on FirmaDigitaleException {
      rethrow;
    } catch (e) {
      AppLogger.d('❌ [OtpGenerate] Eccezione inattesa: $e');
      throw FirmaDigitaleException(
        message: 'Errore inaspettato: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// 3️⃣ Verifica il codice OTP
  /// POST /firma-digitale/otp/verify
  /// Max 3 tentativi, scadenza 5 minuti
  static Future<OTPVerifyResponse> verificaOTP({
    required String otpId,
    required String otpCode,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/firma-digitale/otp/verify';
      final requestBody = {'otp_id': otpId, 'otp_code': otpCode};

      AppLogger.d('✅ Verifico OTP: $otpId');
      AppLogger.d('✅ [OtpVerify] url=$url');
      AppLogger.d(
        '✅ [OtpVerify] hasAuthHeader=${headers.containsKey('Authorization')}',
      );
      AppLogger.d('✅ [OtpVerify] requestBody=$requestBody');

      final response = await HttpClientService.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      AppLogger.d('Status code: ${response.statusCode}');
      AppLogger.d('✅ [OtpVerify] content-type=${response.headers['content-type']}');
      final bodyPreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      AppLogger.d('✅ [OtpVerify] body preview: $bodyPreview');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.d(
          '✅ [OtpVerify] data keys=${data is Map<String, dynamic> ? data.keys.toList() : 'not-a-map'}',
        );

        if (data['success'] == true && data['otp'] != null) {
          return OTPVerifyResponse.fromJson(data['otp']);
        } else if (data['success'] == true && data['otp_id'] != null) {
          final otpVerifyFallbackPayload = {
            'id': data['otp_id'].toString(),
            'verified': true,
            'verified_at': DateTime.now().toIso8601String(),
          };
          AppLogger.d(
            '✅ [OtpVerify] formato alternativo rilevato, payload normalizzato=$otpVerifyFallbackPayload',
          );
          return OTPVerifyResponse.fromJson(otpVerifyFallbackPayload);
        } else {
          final rawTentativi = data['tentativi_rimasti'];
          final tentativiRimasti = rawTentativi is int
              ? rawTentativi
              : (rawTentativi is num
                  ? rawTentativi.toInt()
                  : (rawTentativi is String
                      ? int.tryParse(rawTentativi)
                      : null));
          throw FirmaDigitaleException(
            message: data['error'] ?? 'OTP non valido',
            code: data['code'] ?? 'INVALID_OTP',
            tentativiRimasti: tentativiRimasti,
          );
        }
      } else if (response.statusCode == 401) {
        AppLogger.d('❌ [OtpVerify] 401 body=${response.body}');
        throw FirmaDigitaleException(
          message: 'Autenticazione richiesta',
          code: 'UNAUTHORIZED',
        );
      } else {
        AppLogger.d(
          '❌ [OtpVerify] status=${response.statusCode} body=${response.body}',
        );
        throw FirmaDigitaleException(
          message: 'Errore verifica OTP: ${response.statusCode}',
          code: 'SERVER_ERROR',
        );
      }
    } on SocketException catch (e) {
      AppLogger.d('❌ [OtpVerify] SocketException: $e');
      throw FirmaDigitaleException(
        message: 'Errore di connessione: $e',
        code: 'CONNECTION_ERROR',
      );
    } on FirmaDigitaleException {
      rethrow;
    } catch (e) {
      AppLogger.d('❌ [OtpVerify] Eccezione inattesa: $e');
      throw FirmaDigitaleException(
        message: 'Errore inaspettato: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// 4️⃣ Firma il documento (FES - Firma Elettronica Semplice)
  /// POST /firma-digitale/sign
  /// Invia: otp_id, richiesta_id, documento_contenuto, device_info, app_version, ip_address
  static Future<FirmaDigitale> firmaDocumento({
    required String otpId,
    required int richiestaId,
    required String documentoContenuto,
    required String deviceType, // iOS o Android
    required String deviceModel,
    required String appVersion,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/firma-digitale/sign';
      final requestBody = {
        'otp_id': otpId,
        'richiesta_id': richiestaId,
        'documento_contenuto': documentoContenuto,
        'device_info': {'device_type': deviceType, 'device_model': deviceModel},
        'app_version': appVersion,
        'ip_address': 'auto',
      };

      AppLogger.d('🔐 Firmo documento con OTP: $otpId');
      AppLogger.d(
        '🔐 [Sign] url=$url richiestaId=$richiestaId contenutoLen=${documentoContenuto.length}',
      );
      AppLogger.d(
        '🔐 [Sign] hasAuthHeader=${headers.containsKey('Authorization')} requestBody(device)=${requestBody['device_info']}',
      );

      final response = await HttpClientService.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      AppLogger.d('Status code: ${response.statusCode}');
      final bodyPreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      AppLogger.d('🔐 [Sign] body preview: $bodyPreview');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.d(
          '🔐 [Sign] data keys=${data is Map<String, dynamic> ? data.keys.toList() : 'not-a-map'}',
        );
        AppLogger.d(
          '🔐 [Sign] success=${data is Map<String, dynamic> ? data['success'] : null} message=${data is Map<String, dynamic> ? data['message'] : null} code=${data is Map<String, dynamic> ? data['code'] : null}',
        );

        if (data['success'] == true && data['firma'] != null) {
          AppLogger.d(
            '✅ [Sign] formato annidato rilevato: firma keys=${(data['firma'] as Map<String, dynamic>).keys.toList()}',
          );
          return FirmaDigitale.fromJson(data['firma']);
        } else if (data['success'] == true && data['firma_id'] != null) {
          final normalizedFirma = {
            'id': data['firma_id'].toString(),
            'richiesta_id': richiestaId,
            'firma_timestamp':
                (data['firma_timestamp'] ?? DateTime.now().toIso8601String())
                    .toString(),
            'metodo_firma': (data['firma_tipo'] ?? 'FES').toString(),
            'status': 'valida',
            'hash_verificato': true,
          };
          AppLogger.d(
            '✅ [Sign] formato top-level rilevato, payload normalizzato=$normalizedFirma',
          );
          return FirmaDigitale.fromJson(normalizedFirma);
        } else {
          AppLogger.d(
            '❌ [Sign] success true ma payload firma non riconosciuto: $data',
          );
          throw FirmaDigitaleException(
            message: data['error'] ?? 'Errore nella firma del documento',
            code: data['code'] ?? 'UNKNOWN',
          );
        }
      } else if (response.statusCode == 401) {
        AppLogger.d('❌ [Sign] 401 body=${response.body}');
        throw FirmaDigitaleException(
          message: 'Autenticazione richiesta',
          code: 'UNAUTHORIZED',
          status: response.statusCode,
        );
      } else if (response.statusCode == 409) {
        AppLogger.d('⚠️ [Sign] 409 body=${response.body}');
        Map<String, dynamic>? parsed;
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            parsed = data;
          }
        } catch (_) {
          parsed = null;
        }

        if (parsed != null) {
          throw FirmaDigitaleException(
            message:
                (parsed['error'] ??
                        parsed['message'] ??
                        'Documento già firmato')
                    .toString(),
            code: (parsed['code'] ?? 'document_already_signed').toString(),
            status: (parsed['status'] as num?)?.toInt() ?? 409,
            details:
                parsed['details'] is Map<String, dynamic>
                    ? Map<String, dynamic>.from(parsed['details'])
                    : Map<String, dynamic>.from(parsed),
          );
        } else {
          throw FirmaDigitaleException(
            message: 'Documento già firmato',
            code: 'document_already_signed',
            status: 409,
          );
        }
      } else {
        AppLogger.d('❌ [Sign] status=${response.statusCode} body=${response.body}');
        Map<String, dynamic>? parsed;
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            parsed = data;
          }
        } catch (e) { AppLogger.d("ignored: $e"); }
        throw FirmaDigitaleException(
          message:
              (parsed?['error'] ??
                      parsed?['message'] ??
                      'Errore firma documento: ${response.statusCode}')
                  .toString(),
          code: (parsed?['code'] ?? 'SERVER_ERROR').toString(),
          status: response.statusCode,
          details: parsed,
        );
      }
    } on SocketException catch (e) {
      AppLogger.d('❌ [Sign] SocketException: $e');
      throw FirmaDigitaleException(
        message: 'Errore di connessione: $e',
        code: 'CONNECTION_ERROR',
      );
    } on FirmaDigitaleException {
      rethrow;
    } catch (e) {
      AppLogger.d('❌ [Sign] Eccezione inattesa: $e');
      throw FirmaDigitaleException(
        message: 'Errore inaspettato: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// 5️⃣ Ottiene lo stato della firma
  /// GET /firma-digitale/{richiesta_id}/status
  static Future<FirmaStatus> ottieniStatoFirma(int richiestaId) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/firma-digitale/$richiestaId/status';

      AppLogger.d('📊 Controllo stato firma: $richiestaId');

      final response = await HttpClientService.get(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.d('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.d(
          '📊 [Status] data keys=${data is Map<String, dynamic> ? data.keys.toList() : 'not-a-map'}',
        );

        if (data is Map<String, dynamic>) {
          final hasTopLevelStatus =
              data.containsKey('firmato') ||
              data.containsKey('firma_id') ||
              data.containsKey('documento_url') ||
              data.containsKey('documento_download_url');
          final isSuccessEnvelope = data['success'] == true;

          if (!isSuccessEnvelope && !hasTopLevelStatus) {
            throw FirmaDigitaleException(
              message:
                  (data['error'] ?? data['message'] ?? 'Errore stato firma')
                      .toString(),
              code: (data['code'] ?? 'STATUS_ERROR').toString(),
            );
          }

          if (data['firma'] is Map<String, dynamic>) {
            final firmaPayload = Map<String, dynamic>.from(data['firma']);
            if (!firmaPayload.containsKey('firmato')) {
              firmaPayload['firmato'] = true;
            }
            if (!firmaPayload.containsKey('richiesta_id')) {
              firmaPayload['richiesta_id'] = richiestaId;
            }
            if (data['documento_url'] != null) {
              firmaPayload['documento_url'] = data['documento_url'];
            }
            if (data['documento_download_url'] != null) {
              firmaPayload['documento_download_url'] =
                  data['documento_download_url'];
            }
            AppLogger.d('📊 [Status] formato annidato firma rilevato');
            return FirmaStatus.fromJson(firmaPayload);
          }

          AppLogger.d('📊 [Status] formato top-level rilevato');
          final normalized =
              Map<String, dynamic>.from(data)
                ..putIfAbsent('richiesta_id', () => richiestaId)
                ..putIfAbsent('firmato', () => false);
          return FirmaStatus.fromJson(normalized);
        }

        throw FirmaDigitaleException(
          message:
              data is Map<String, dynamic>
                  ? (data['error'] ?? data['message'] ?? 'Errore stato firma')
                      .toString()
                  : 'Errore stato firma',
          code:
              data is Map<String, dynamic>
                  ? (data['code'] ?? 'STATUS_ERROR').toString()
                  : 'STATUS_ERROR',
        );
      } else if (response.statusCode == 404) {
        throw FirmaDigitaleException(
          message: 'Firma non trovata',
          code: 'NOT_FOUND',
        );
      } else if (response.statusCode == 401) {
        throw FirmaDigitaleException(
          message: 'Autenticazione richiesta',
          code: 'UNAUTHORIZED',
        );
      } else {
        throw FirmaDigitaleException(
          message: 'Errore retrieving firma status: ${response.statusCode}',
          code: 'SERVER_ERROR',
        );
      }
    } on SocketException catch (e) {
      throw FirmaDigitaleException(
        message: 'Errore di connessione: $e',
        code: 'CONNECTION_ERROR',
      );
    } on FirmaDigitaleException {
      rethrow;
    } catch (e) {
      throw FirmaDigitaleException(
        message: 'Errore inaspettato: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// 6️⃣ Verifica l'integrità della firma
  /// GET /firma-digitale/verifica/{firma_id}
  /// Verifica: hash, OTP validato, timestamp valido
  static Future<VerificaIntegrita> verificaIntegrita(String firmaId) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/firma-digitale/verifica/$firmaId';

      AppLogger.d('🔍 Verifico integrità firma: $firmaId');

      final response = await HttpClientService.get(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.d('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['verifica'] != null) {
          return VerificaIntegrita.fromJson(data['verifica']);
        } else {
          throw FirmaDigitaleException(
            message: 'Errore verifica integrità',
            code: 'VERIFICATION_ERROR',
          );
        }
      } else if (response.statusCode == 404) {
        throw FirmaDigitaleException(
          message: 'Firma non trovata',
          code: 'NOT_FOUND',
        );
      } else if (response.statusCode == 401) {
        throw FirmaDigitaleException(
          message: 'Autenticazione richiesta',
          code: 'UNAUTHORIZED',
        );
      } else {
        throw FirmaDigitaleException(
          message: 'Errore verifica integrità: ${response.statusCode}',
          code: 'SERVER_ERROR',
        );
      }
    } on SocketException catch (e) {
      throw FirmaDigitaleException(
        message: 'Errore di connessione: $e',
        code: 'CONNECTION_ERROR',
      );
    } on FirmaDigitaleException {
      rethrow;
    } catch (e) {
      throw FirmaDigitaleException(
        message: 'Errore inaspettato: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }
}

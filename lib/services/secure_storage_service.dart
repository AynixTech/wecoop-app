import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

/// Servizio centralizzato per Flutter Secure Storage con gestione errori
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Legge un valore dallo storage con gestione errori BadPaddingException
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      if (e.message?.contains('BadPaddingException') == true ||
          e.message?.contains('BAD_DECRYPT') == true) {
        print('Errore decrittazione per chiave "$key", pulizia storage corrotto');
        
        // Elimina la chiave corrotta
        await _storage.delete(key: key);
        
        // Se e' una chiave critica (JWT), pulisci tutto
        if (key == 'jwt_token' || key == 'user_id' || key == 'user_nicename') {
          print('Chiave critica corrotta, pulizia completa storage');
          await deleteAll();
        }
        
        return null;
      }
      
      // Altri errori
      print('Errore lettura secure storage ($key): $e');
      return null;
    } catch (e) {
      print('Errore generico lettura secure storage ($key): $e');
      return null;
    }
  }

  /// Scrive un valore nello storage
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('Errore scrittura secure storage ($key): $e');
      rethrow;
    }
  }

  /// Elimina un valore dallo storage
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Errore eliminazione secure storage ($key): $e');
    }
  }

  /// Elimina tutti i valori dallo storage
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      print('Storage pulito completamente');
    } catch (e) {
      print('Errore pulizia storage: $e');
    }
  }

  /// Legge tutti i valori (utile per debug)
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } on PlatformException catch (e) {
      if (e.message?.contains('BadPaddingException') == true ||
          e.message?.contains('BAD_DECRYPT') == true) {
        print('Storage corrotto rilevato durante readAll, pulizia completa');
        await deleteAll();
        return {};
      }
      print('Errore readAll secure storage: $e');
      return {};
    } catch (e) {
      print('Errore generico readAll: $e');
      return {};
    }
  }

  /// Verifica se una chiave esiste (con gestione errori)
  Future<bool> containsKey({required String key}) async {
    try {
      final value = await read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  /// Verifica integrita' dello storage e pulisce se corrotto
  Future<bool> checkIntegrity() async {
    try {
      await _storage.readAll();
      return true;
    } on PlatformException catch (e) {
      if (e.message?.contains('BadPaddingException') == true ||
          e.message?.contains('BAD_DECRYPT') == true) {
        print('Storage corrotto rilevato, pulizia automatica');
        await deleteAll();
        return false;
      }
      return true;
    } catch (e) {
      return true;
    }
  }
}

/// Configuración central de la API de WeCoop.
///
/// Tutti i servizi puntano al backend Node/Express. L'URL di produzione è
/// il default: nessun dart-define obbligatorio. Opzionale solo per staging:
/// `--dart-define=WECOOP_API_URL=...`
class ApiConfig {
  /// Base del backend Node, ej: https://wecoop-backend-s9gl.onrender.com/api
  static const String baseUrl = String.fromEnvironment(
    'WECOOP_API_URL',
    defaultValue: 'https://wecoop-backend-s9gl.onrender.com/api',
  );

  /// Endpoint de login (antes jwt-auth/v1/token de WordPress).
  static const String loginUrl = '$baseUrl/auth/login';
}

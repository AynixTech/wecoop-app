/// Configuración central de la API de WeCoop.
///
/// Todos los servicios de la app apuntan al backend Node/Express de WeCoop
/// (antes se usaba WordPress en www.wecoop.org/wp-json). La URL puede
/// sobreescribirse en compilación con --dart-define=WECOOP_API_URL=...
class ApiConfig {
  /// Base del backend Node, ej: https://wecoop-backend-s9gl.onrender.com/api
  static const String baseUrl = String.fromEnvironment(
    'WECOOP_API_URL',
    defaultValue: 'https://wecoop-backend-s9gl.onrender.com/api',
  );

  /// API key compartida para endpoints llamados sin login (ej. service-requests).
  static const String apiKey = String.fromEnvironment(
    'WECOOP_API_KEY',
    defaultValue: 'af9a4cfa37958761a464c06a837d6860',
  );

  /// Endpoint de login (antes jwt-auth/v1/token de WordPress).
  static const String loginUrl = '$baseUrl/auth/login';
}

class AppConfig {
  static const _configuredApiUrl = String.fromEnvironment('API_BASE_URL');
  static const _defaultApiUrl = 'https://backend-ofertia.vercel.app';

  static String get apiBaseUrl {
    if (_configuredApiUrl.isNotEmpty) return _configuredApiUrl;
    return _defaultApiUrl;
  }
}

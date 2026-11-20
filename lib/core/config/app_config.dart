import 'package:flutter/foundation.dart';

class AppConfig {
  static const _configuredApiUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_configuredApiUrl.isNotEmpty) return _configuredApiUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

}

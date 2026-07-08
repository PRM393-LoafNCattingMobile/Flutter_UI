import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  // Android Emulator reaches the host machine through 10.0.2.2.
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5117/api';

  // iOS simulator, Windows desktop, and Flutter web can use localhost.
  static const String localhostBaseUrl = 'http://localhost:5117/api';

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return localhostBaseUrl;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidEmulatorBaseUrl,
      _ => localhostBaseUrl,
    };
  }
}

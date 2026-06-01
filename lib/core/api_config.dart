class ApiConfig {
  // Android Emulator reaches the host machine through 10.0.2.2.
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5117/api';

  // Use this for Windows desktop or Flutter web local runs.
  static const String localhostBaseUrl = 'http://localhost:5117/api';

  // Change to localhostBaseUrl for Windows/web, or to your LAN/Tailscale IP for a physical phone.
  static const String baseUrl = androidEmulatorBaseUrl;
}

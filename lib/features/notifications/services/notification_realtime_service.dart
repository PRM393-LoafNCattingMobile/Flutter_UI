import 'dart:async';
import 'dart:convert';

import 'package:loafncatting_mobile/core/api_config.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

class NotificationRealtimeService {
  static const _connectionTimeout = Duration(seconds: 5);

  HubConnection? _connection;
  bool _handlersRegistered = false;
  final _created = StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get created => _created.stream;

  String get _hubUrl =>
      '${ApiConfig.baseUrl.replaceFirst(RegExp(r'/api$'), '')}/hubs/notifications';

  Future<String> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('authUser');
    if (raw == null || raw.isEmpty) return '';

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded['token']?.toString() ?? '';
    }

    return '';
  }

  Future<void> _ensureConnected() async {
    _connection ??= HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(accessTokenFactory: _readToken),
        )
        .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 20000])
        .build();

    if (!_handlersRegistered) {
      _handlersRegistered = true;
      _connection!.on('NotificationCreated', _handleNotificationCreated);
    }

    if (_connection!.state != HubConnectionState.Connected) {
      final startFuture = _connection!.start();
      if (startFuture != null) {
        await startFuture.timeout(_connectionTimeout);
      }
    }
  }

  void _handleNotificationCreated(List<Object?>? parameters) {
    final raw = parameters == null || parameters.isEmpty ? null : parameters.first;
    if (raw is! Map) return;

    _created.add(AppNotification.fromJson(Map<String, dynamic>.from(raw)));
  }

  Future<void> joinUserNotifications() async {
    await _ensureConnected();
    await _connection!
        .invoke('JoinUserNotifications')
        .timeout(_connectionTimeout);
  }

  Future<void> stop() async {
    if (_connection != null) {
      await _connection!.stop();
      _connection = null;
      _handlersRegistered = false;
    }
  }

  Future<void> dispose() async {
    await stop();
    await _created.close();
  }
}

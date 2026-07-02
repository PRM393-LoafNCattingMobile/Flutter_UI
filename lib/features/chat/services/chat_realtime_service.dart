import 'dart:async';
import 'dart:convert';

import 'package:loafncatting_mobile/core/api_config.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatRealtimeService {
  static const _connectionTimeout = Duration(seconds: 5);

  HubConnection? _connection;
  bool _handlersRegistered = false;
  final _threadUpdates = StreamController<List<ChatMessage>>.broadcast();
  final _inboxUpdates = StreamController<int>.broadcast();

  Stream<List<ChatMessage>> get threadUpdates => _threadUpdates.stream;
  Stream<int> get inboxUpdates => _inboxUpdates.stream;

  String get _hubUrl =>
      '${ApiConfig.baseUrl.replaceFirst(RegExp(r'/api$'), '')}/hubs/support-chat';

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
      _connection!.on('ThreadUpdated', _handleThreadUpdated);
      _connection!.on('InboxUpdated', _handleInboxUpdated);
    }

    if (_connection!.state != HubConnectionState.Connected) {
      final startFuture = _connection!.start();
      if (startFuture != null) {
        await startFuture.timeout(_connectionTimeout);
      }
    }
  }

  void _handleThreadUpdated(List<Object?>? parameters) {
    final raw = parameters == null || parameters.isEmpty ? null : parameters.first;
    if (raw is! List) return;

    final messages = raw
        .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _threadUpdates.add(messages);
  }

  void _handleInboxUpdated(List<Object?>? parameters) {
    final raw = parameters == null || parameters.isEmpty ? null : parameters.first;
    if (raw is num) {
      _inboxUpdates.add(raw.toInt());
    }
  }

  Future<void> joinConversation(int conversationId) async {
    await _ensureConnected();
    await _connection!
        .invoke('JoinConversation', args: [conversationId])
        .timeout(_connectionTimeout);
  }

  Future<void> joinStaffInbox() async {
    await _ensureConnected();
    await _connection!.invoke('JoinStaffInbox').timeout(_connectionTimeout);
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
    await _threadUpdates.close();
    await _inboxUpdates.close();
  }
}

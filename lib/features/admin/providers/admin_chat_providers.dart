import 'dart:async';

import 'package:loafncatting_mobile/features/admin/models/admin_chat_models.dart';
import 'package:loafncatting_mobile/features/chat/services/chat_realtime_service.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

class AdminChatInboxProvider extends LoadableProvider {
  AdminChatInboxProvider(this.api, {ChatRealtimeService? realtime})
      : _realtime = realtime ?? ChatRealtimeService() {
    _inboxSubscription = _realtime.inboxUpdates.listen((_) => refreshSilently());
  }

  final ApiService api;
  final ChatRealtimeService _realtime;
  List<AdminConversationSummary> conversations = [];
  StreamSubscription<int>? _inboxSubscription;
  bool _joinedInbox = false;
  bool _isJoiningInbox = false;

  Future<void> load() async => run(() async {
        conversations = await api.getAdminConversations();
        if (!_joinedInbox) {
          unawaited(_joinInboxSafely());
        }
      });

  Future<void> _joinInboxSafely() async {
    if (_joinedInbox || _isJoiningInbox) return;

    _isJoiningInbox = true;
    try {
      await _realtime.joinStaffInbox();
      _joinedInbox = true;
    } catch (_) {
      // Keep inbox usable even when realtime is temporarily unavailable.
    } finally {
      _isJoiningInbox = false;
    }
  }

  Future<void> refreshSilently() async {
    try {
      conversations = await api.getAdminConversations();
      notifyListeners();
    } catch (_) {
      // Keep the current inbox visible if a background refresh fails.
    }
  }

  @override
  void dispose() {
    _inboxSubscription?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}

class AdminChatDetailProvider extends LoadableProvider {
  AdminChatDetailProvider(this.api, {ChatRealtimeService? realtime})
      : _realtime = realtime ?? ChatRealtimeService();

  final ApiService api;
  final ChatRealtimeService _realtime;
  List<ChatMessage> messages = [];
  int? conversationId;
  StreamSubscription<List<ChatMessage>>? _threadSubscription;

  Future<void> load(int nextConversationId) async => run(() async {
        conversationId = nextConversationId;
        messages = [];
        messages = await api.getAdminConversationMessages(nextConversationId);
        await _threadSubscription?.cancel();
        _threadSubscription = _realtime.threadUpdates.listen((items) {
          if (items.isEmpty) return;
          if (items.first.conversationId != conversationId) return;
          messages = items;
          notifyListeners();
        });
        unawaited(_joinConversationSafely(nextConversationId));
      });

  Future<void> _joinConversationSafely(int nextConversationId) async {
    try {
      await _realtime.joinConversation(nextConversationId);
    } catch (_) {
      // The screen should stay usable even if realtime cannot connect yet.
    }
  }

  Future<void> sendMessage(String content) async {
    final activeConversationId = conversationId;
    if (activeConversationId == null) return;

    await run(() async {
      messages = await api.sendAdminMessage(activeConversationId, content);
    });
  }

  @override
  void dispose() {
    _threadSubscription?.cancel();
    _realtime.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _enteredChatScope = false;
  String? _lastScrollSignature;
  NotificationProvider? _notifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user == null) return;
      context.read<ChatProvider>().load(user.userId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_enteredChatScope) {
      _notifications = context.read<NotificationProvider>();
      _notifications!.enterChatScope();
      _enteredChatScope = true;
    }
  }

  @override
  void dispose() {
    if (_enteredChatScope) {
      _notifications?.leaveChatScope();
    }
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  void _syncScrollPosition(List<ChatMessage> messages) {
    final signature = messages.isEmpty
        ? 'empty'
        : '${messages.length}:${messages.last.messageId}:${messages.last.sentAt.toIso8601String()}';
    if (_lastScrollSignature == signature) return;

    final animated = _lastScrollSignature != null;
    _lastScrollSignature = signature;
    _scrollToBottom(animated: animated);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.chatTitle)),
        body: CafeSurface(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ErrorView(AppStrings.checkoutLoginRequiredMessage),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (_) => false),
                    child: const Text(AppStrings.goToLoginButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final userId = user.userId;
    _syncScrollPosition(provider.messages);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.chatTitle)),
      body: CafeSurface(
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading && provider.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      children: provider.messages
                          .map(
                            (message) => Align(
                              alignment: message.sender == 'customer'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 280),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: message.sender == 'customer'
                                      ? loafOrange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: message.sender == 'customer'
                                      ? null
                                      : Border.all(color: loafBorder),
                                ),
                                child: Text(
                                  message.content,
                                  style: TextStyle(
                                    color: message.sender == 'customer'
                                        ? Colors.white
                                        : loafBrown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: CafeCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: AppStrings.chatMessageHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        controller.clear();
                        await provider.send(userId, text);
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

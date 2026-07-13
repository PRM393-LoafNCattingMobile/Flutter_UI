import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_chat_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_chat_bubble.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class AdminChatDetailScreen extends StatefulWidget {
  const AdminChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.customerName,
  });

  final int conversationId;
  final String customerName;

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _enteredChatScope = false;
  String? _lastScrollSignature;
  NotificationProvider? _notifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminChatDetailProvider>().load(widget.conversationId);
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
    _controller.dispose();
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
    final provider = context.watch<AdminChatDetailProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.customerName)),
      body: CafeSurface(
        child: Column(
          children: [
            Expanded(child: _buildBody(context, provider)),
            _buildComposer(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminChatDetailProvider provider) {
    if (provider.isLoading && provider.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.messages.isEmpty) {
      return ErrorView(
        provider.error!,
        onRetry: () => provider.load(widget.conversationId),
      );
    }
    if (provider.messages.isEmpty) {
      return const EmptyView(AppStrings.adminChatEmptyMessage);
    }

    _syncScrollPosition(provider.messages);
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        return AdminChatBubble(message: provider.messages[index]);
      },
    );
  }

  Widget _buildComposer(
    BuildContext context,
    AdminChatDetailProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: CafeCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: AppStrings.adminChatComposerHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            IconButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;
                      _controller.clear();
                      await provider.sendMessage(text);
                    },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

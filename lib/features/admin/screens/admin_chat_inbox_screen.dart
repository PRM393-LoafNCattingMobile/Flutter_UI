import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_chat_providers.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_chat_detail_screen.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_chat_conversation_tile.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class AdminChatInboxScreen extends StatefulWidget {
  const AdminChatInboxScreen({super.key});

  @override
  State<AdminChatInboxScreen> createState() => _AdminChatInboxScreenState();
}

class _AdminChatInboxScreenState extends State<AdminChatInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminChatInboxProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminChatInboxProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminChatTitle)),
      body: CafeSurface(
        child: Column(
          children: [
            const CafeHeroHeader(
              title: AppStrings.adminChatTitle,
              subtitle: AppStrings.adminChatSubtitle,
              icon: Icons.chat_bubble_outline,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.load,
                child: _buildBody(context, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdminChatInboxProvider provider) {
    if (provider.isLoading && provider.conversations.isEmpty) {
      return ListView(
        children: const [
          SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (provider.error != null && provider.conversations.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: 400,
            child: ErrorView(
              provider.error!,
              onRetry: provider.load,
            ),
          ),
        ],
      );
    }

    if (provider.conversations.isEmpty) {
      return ListView(
        children: const [
          SizedBox(
            height: 400,
            child: EmptyView(AppStrings.adminChatEmptyMessage),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: provider.conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final summary = provider.conversations[index];
        return AdminChatConversationTile(
          summary: summary,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminChatDetailScreen(
                  conversationId: summary.conversationId,
                  customerName: summary.customerName,
                ),
              ),
            );

            if (!context.mounted) return;
            await context.read<AdminChatInboxProvider>().load();
          },
        );
      },
    );
  }
}

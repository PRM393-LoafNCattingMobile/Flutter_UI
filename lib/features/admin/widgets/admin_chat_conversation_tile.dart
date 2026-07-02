import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_chat_models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';

class AdminChatConversationTile extends StatelessWidget {
  const AdminChatConversationTile({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final AdminConversationSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CafeCard(
      padding: const EdgeInsets.all(0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: loafLightCream,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              summary.customerName.isEmpty
                  ? '?'
                  : summary.customerName[0].toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: loafOrange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        title: Text(summary.customerName, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              summary.lastMessageSender == 'store' ? 'Hỗ trợ' : 'Khách hàng',
              style: theme.textTheme.labelMedium?.copyWith(
                color: loafOrange,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              summary.lastMessage ?? 'Chưa có tin nhắn',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: loafMuted),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              summary.lastMessageSentAt == null
                  ? '--:--'
                  : formatAdminDateTime(summary.lastMessageSentAt!),
              style: theme.textTheme.bodySmall?.copyWith(color: loafMuted),
            ),
            const SizedBox(height: 6),
            if (summary.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${summary.unreadCount}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

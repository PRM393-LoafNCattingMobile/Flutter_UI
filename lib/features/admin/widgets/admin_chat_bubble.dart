import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';

class AdminChatBubble extends StatelessWidget {
  const AdminChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromStore = message.sender == 'store';
    final theme = Theme.of(context);

    return Align(
      alignment: fromStore ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: fromStore
              ? theme.colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: fromStore ? null : Border.all(color: loafBorder),
        ),
        child: Column(
          crossAxisAlignment:
              fromStore ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              fromStore
                  ? AppStrings.adminChatStoreLabel
                  : AppStrings.adminChatCustomerLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: fromStore
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(
                color: fromStore
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatAdminDateTime(message.sentAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: fromStore
                    ? theme.colorScheme.onPrimary.withValues(alpha: .78)
                    : loafMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/features/chat/screens/chat_screen.dart';
import 'package:loafncatting_mobile/features/notifications/screens/notifications_screen.dart';
import 'package:loafncatting_mobile/features/store/screens/store_location_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount = _maybeWatchNotifications(context)?.unreadCount ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeNavLabel)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const CafeHeroHeader(
              title: AppStrings.moreHeroTitle,
              subtitle: AppStrings.moreHeroSubtitle,
              icon: Icons.more_horiz,
            ),
            _MoreItem(
                icon: Icons.notifications_outlined,
                title: AppStrings.notificationsTitle,
                subtitle: AppStrings.notificationsMenuSubtitle,
                screen: const NotificationsScreen(),
                badgeCount: unreadCount,
                requiresAuth: true),
            const _MoreItem(
                icon: Icons.map_outlined,
                title: AppStrings.storeLocationTitle,
                subtitle: AppStrings.storeLocationMenuSubtitle,
                screen: StoreLocationScreen()),
            const _MoreItem(
                icon: Icons.chat_outlined,
                title: AppStrings.chatTitle,
                subtitle: AppStrings.chatMenuSubtitle,
                screen: ChatScreen(),
                requiresAuth: true),
          ],
        ),
      ),
    );
  }
}

NotificationProvider? _maybeWatchNotifications(BuildContext context) {
  try {
    return Provider.of<NotificationProvider>(context);
  } on ProviderNotFoundException {
    return null;
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.screen,
      this.badgeCount = 0,
      this.requiresAuth = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;
  final int badgeCount;
  final bool requiresAuth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (requiresAuth && context.read<AuthProvider>().user == null) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (_) => false);
            return;
          }

          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: CafeCard(
          child: Row(
            children: [
              CafeIconBadge(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        if (badgeCount > 0)
                          Container(
                            constraints: const BoxConstraints(minWidth: 24),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: loafOrange,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: loafMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

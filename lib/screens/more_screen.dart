import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/chat_screen.dart';
import 'package:loafncatting_mobile/screens/notifications_screen.dart';
import 'package:loafncatting_mobile/screens/profile_screen.dart';
import 'package:loafncatting_mobile/screens/store_location_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.moreTitle)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: const [
            CafeHeroHeader(
              title: AppStrings.moreHeroTitle,
              subtitle: AppStrings.moreHeroSubtitle,
              icon: Icons.more_horiz,
            ),
            _MoreItem(
                icon: Icons.notifications_outlined,
                title: AppStrings.notificationsTitle,
                subtitle: AppStrings.notificationsMenuSubtitle,
                screen: NotificationsScreen(),
                requiresAuth: true),
            _MoreItem(
                icon: Icons.map_outlined,
                title: AppStrings.storeLocationTitle,
                subtitle: AppStrings.storeLocationMenuSubtitle,
                screen: StoreLocationScreen()),
            _MoreItem(
                icon: Icons.chat_outlined,
                title: AppStrings.chatTitle,
                subtitle: AppStrings.chatMenuSubtitle,
                screen: ChatScreen(),
                requiresAuth: true),
            _MoreItem(
                icon: Icons.person_outline,
                title: AppStrings.profileTitle,
                subtitle: AppStrings.profileMenuSubtitle,
                screen: ProfileScreen()),
          ],
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.screen,
      this.requiresAuth = false});

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;
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
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
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

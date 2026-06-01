import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/screens/chat_screen.dart';
import 'package:loafncatting_mobile/screens/notifications_screen.dart';
import 'package:loafncatting_mobile/screens/profile_screen.dart';
import 'package:loafncatting_mobile/screens/store_location_screen.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: const [
            CafeHeroHeader(
              title: 'Cafe corner',
              subtitle: 'Notifications, support, profile, and directions.',
              icon: Icons.more_horiz,
            ),
            _MoreItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Cafe updates and order notes',
                screen: NotificationsScreen()),
            _MoreItem(
                icon: Icons.map_outlined,
                title: 'Store Location',
                subtitle: 'Find your way to the cafe',
                screen: StoreLocationScreen()),
            _MoreItem(
                icon: Icons.chat_outlined,
                title: 'Chat',
                subtitle: 'Ask about hours, reservations, and best sellers',
                screen: ChatScreen()),
            _MoreItem(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Account details and logout',
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
      required this.screen});

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
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

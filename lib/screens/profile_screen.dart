import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            CafeHeroHeader(
              title: user?.name ?? AppStrings.profileGuestTitle,
              subtitle: user == null
                  ? AppStrings.profileGuestSubtitle
                  : AppStrings.localizedRoleName(user.roleName),
              icon: Icons.person,
            ),
            CafeCard(
              child: Column(
                children: [
                  _ProfileRow(
                      icon: Icons.mail_outline,
                      label: AppStrings.emailLabel,
                      value: user?.email ?? ''),
                  const Divider(height: 22),
                  _ProfileRow(
                      icon: Icons.phone_outlined,
                      label: AppStrings.phoneLabel,
                      value: user?.phoneNumber ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await SessionCoordinator().logout(
                  auth: auth,
                  cart: context.read<CartProvider>(),
                  reservations: context.read<ReservationProvider>(),
                  notifications: context.read<NotificationProvider>(),
                  chat: context.read<ChatProvider>(),
                );
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logoutButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: loafOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: loafMuted)),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}

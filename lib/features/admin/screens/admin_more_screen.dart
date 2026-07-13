import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_store_location_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_tables_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_users_screen.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

/// Tab "Thêm" của khu quản lý: điều hướng tới các màn phụ + đăng xuất.
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionCoordinator().logout(
      auth: context.read<AuthProvider>(),
      cart: context.read<CartProvider>(),
      reservations: context.read<ReservationProvider>(),
      orderHistory: context.read<OrderHistoryProvider>(),
      notifications: context.read<NotificationProvider>(),
      chat: context.read<ChatProvider>(),
    );
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        RoleRouting.isAdmin(context.watch<AuthProvider>().user?.roleName);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminMoreTitle)),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            CafeCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.table_restaurant_outlined),
                    title: const Text(AppStrings.adminMoreManageTables),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminTablesScreen()),
                    ),
                  ),
                  if (isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text(AppStrings.adminMoreManageUsers),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdminUsersScreen()),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.storefront_outlined),
                      title: const Text(AppStrings.adminMoreStoreLocation),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AdminStoreLocationScreen()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logoutButton),
            ),
          ],
        ),
      ),
    );
  }
}

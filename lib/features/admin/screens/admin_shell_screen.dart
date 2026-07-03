import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_catalog_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_chat_inbox_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_cats_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_dashboard_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_more_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_orders_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_reservations_screen.dart';

/// Khung điều hướng cho Admin/Staff với 7 tab: Tổng quan, Đơn hàng, Đặt bàn,
/// Thực đơn, Mèo, Chat, Thêm. Admin và Staff dùng chung khung này; phân quyền
/// hành động nằm trong từng màn.
class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int index = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminOrdersScreen(),
    AdminReservationsScreen(),
    AdminCatalogScreen(),
    AdminCatsScreen(),
    AdminChatInboxScreen(),
    AdminMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 70,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: AppStrings.adminDashboardNavLabel),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: AppStrings.adminOrdersNavLabel),
          NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: AppStrings.adminReservationsNavLabel),
          NavigationDestination(
              icon: Icon(Icons.local_cafe_outlined),
              selectedIcon: Icon(Icons.local_cafe),
              label: AppStrings.adminCatalogNavLabel),
          NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              selectedIcon: Icon(Icons.pets),
              label: AppStrings.adminCatsNavLabel),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: AppStrings.adminChatNavLabel),
          NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: AppStrings.adminMoreNavLabel),
        ],
      ),
    );
  }
}

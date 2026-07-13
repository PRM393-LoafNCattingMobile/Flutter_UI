import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_catalog_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_chat_inbox_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_cats_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_dashboard_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_more_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_orders_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_reservations_screen.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:provider/provider.dart';

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
  StreamSubscription<AppNotification>? _notificationPopupSubscription;

  static const _ordersIndex = 1;
  static const _reservationsIndex = 2;
  static const _catalogIndex = 3;
  static const _catsIndex = 4;

  List<Widget> get _screens => [
        AdminDashboardScreen(onMetricSelected: _openDashboardMetric),
        const AdminOrdersScreen(),
        const AdminReservationsScreen(),
        const AdminCatalogScreen(),
        const AdminCatsScreen(),
        const AdminChatInboxScreen(),
        const AdminMoreScreen(),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = _maybeProvider<AuthProvider>(context);
      final notifications = _maybeProvider<NotificationProvider>(context);
      final user = auth?.user;
      if (user == null || notifications == null) return;
      _notificationPopupSubscription ??=
          notifications.popupNotifications.listen(_showNotificationPopup);
      unawaited(notifications.load(user.userId));
      unawaited(notifications.startRealtime(user.userId));
    });
  }

  void _showNotificationPopup(AppNotification notification) {
    if (!mounted) return;
    final notifications = _maybeProvider<NotificationProvider>(context);
    if (notification.type == 'chat' && notifications?.isChatVisible == true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Text(
          '${notification.title}\n${notification.content}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _openDashboardMetric(AdminDashboardMetric metric) async {
    switch (metric) {
      case AdminDashboardMetric.pendingOrders:
        final statusId = await _lookupOrderStatusId(kPendingOrderStatusName);
        if (!mounted) return;
        unawaited(context
            .read<StaffOrderProvider>()
            .applyFilters(statusId: statusId, date: null));
        setState(() => index = _ordersIndex);
        break;
      case AdminDashboardMetric.todayReservations:
        unawaited(context
            .read<StaffReservationProvider>()
            .applyFilters(statusId: null, date: _todayApiDate()));
        setState(() => index = _reservationsIndex);
        break;
      case AdminDashboardMetric.lowStockProducts:
        context.read<AdminCatalogProvider>().showLowStockProducts();
        setState(() => index = _catalogIndex);
        break;
      case AdminDashboardMetric.catsNotWorking:
        context.read<AdminCatProvider>().showNotWorkingCats();
        setState(() => index = _catsIndex);
        break;
    }
  }

  Future<int?> _lookupOrderStatusId(String statusName) async {
    final provider = context.read<AdminLookupsProvider>();
    await provider.load();
    return _lookupIdByName(
      provider.lookups?.orderStatuses ?? const <LookupItem>[],
      statusName,
    );
  }

  int? _lookupIdByName(List<LookupItem> options, String name) {
    for (final option in options) {
      if (option.name == name) return option.id;
    }
    return null;
  }

  String _todayApiDate() {
    final today = DateTime.now();
    return '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notificationPopupSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens;
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        // Máy thật (nhất là Samsung/One UI) thường để cỡ chữ hệ thống lớn hơn
        // emulator -> nhãn tab bị xuống 2 dòng và lệch so với icon. Khóa nhãn
        // navbar ở scale 1.0 để hiển thị đồng nhất mọi thiết bị.
        maxScaleFactor: 1.0,
        child: NavigationBar(
          selectedIndex: index,
          height: 76,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
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
      ),
    );
  }
}

T? _maybeProvider<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}

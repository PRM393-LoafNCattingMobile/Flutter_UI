import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_shell_screen.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:provider/provider.dart';

class _EmptyApi extends ApiService {
  @override
  Future<List<Order>> getStaffOrders({int? statusId, String? date}) async =>
      const [];
  @override
  Future<List<Reservation>> getStaffReservations(
          {int? statusId, String? date}) async =>
      const [];
  @override
  Future<List<Product>> getProducts({int? categoryId, String? search}) async =>
      const [];
  @override
  Future<List<Cat>> getCats({String? search}) async => const [];
}

void main() {
  group('RoleRouting.homeRouteForRole', () {
    test('Admin goes to the admin shell', () {
      expect(RoleRouting.homeRouteForRole('Admin'), AppRoutes.adminShell);
    });

    test('Staff goes to the admin shell', () {
      expect(RoleRouting.homeRouteForRole('Staff'), AppRoutes.adminShell);
    });

    test('Customer goes to the customer home', () {
      expect(RoleRouting.homeRouteForRole('Customer'), AppRoutes.home);
    });

    test('null or unknown role falls back to the customer home', () {
      expect(RoleRouting.homeRouteForRole(null), AppRoutes.home);
      expect(RoleRouting.homeRouteForRole('Manager'), AppRoutes.home);
    });

    test('role matching is case and whitespace insensitive', () {
      expect(RoleRouting.homeRouteForRole('admin'), AppRoutes.adminShell);
      expect(RoleRouting.homeRouteForRole(' STAFF '), AppRoutes.adminShell);
    });
  });

  testWidgets('AdminShellScreen shows all admin/staff navigation tabs',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => DashboardProvider(_EmptyApi()),
        child: const MaterialApp(home: AdminShellScreen()),
      ),
    );

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.destinations, hasLength(7));
    expect(find.byType(NavigationDestination), findsNWidgets(7));
  });
}

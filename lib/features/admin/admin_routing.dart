import 'package:loafncatting_mobile/core/constants/app_routes.dart';

/// Quyết định màn hình chính sau khi đăng nhập/khôi phục phiên dựa trên vai trò.
///
/// - `Admin`/`Staff` -> khu vực quản lý (`AdminShellScreen`).
/// - Còn lại (`Customer`, null, không xác định) -> `HomeScreen` của khách.
class RoleRouting {
  const RoleRouting._();

  static const adminRole = 'Admin';
  static const staffRole = 'Staff';

  static bool isStaffOrAdmin(String? roleName) {
    final normalized = roleName?.trim().toLowerCase();
    return normalized == 'admin' || normalized == 'staff';
  }

  static bool isAdmin(String? roleName) =>
      roleName?.trim().toLowerCase() == 'admin';

  static String homeRouteForRole(String? roleName) =>
      isStaffOrAdmin(roleName) ? AppRoutes.adminShell : AppRoutes.home;
}

import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

/// Ngưỡng tồn kho thấp dùng cho thẻ cảnh báo ở Dashboard.
const int kLowStockThreshold = 5;

/// Tải các danh mục tra cứu (vai trò, trạng thái, danh mục, giới tính...) để đổ
/// vào dropdown của các form admin/staff. Tải một lần rồi dùng lại.
class AdminLookupsProvider extends LoadableProvider {
  AdminLookupsProvider(this.api);
  final ApiService api;
  AdminLookups? lookups;

  bool get isLoaded => lookups != null;

  Future<void> load({bool force = false}) async {
    if (isLoaded && !force) return;
    await run(() async {
      lookups = await api.getAdminLookups();
    });
  }
}

/// Quản lý sản phẩm + danh mục (Admin CRUD đầy đủ, Staff chỉ cập nhật tồn kho).
class AdminCatalogProvider extends LoadableProvider {
  AdminCatalogProvider(this.api);
  final ApiService api;
  List<Product> products = [];
  List<Category> categories = [];
  String search = '';

  Future<void> load() async => run(() async {
        categories = await api.getAdminCategories();
        products = await api.getAdminProducts(
            search: search.trim().isEmpty ? null : search.trim());
      });

  Future<bool> saveProduct(Map<String, dynamic> body, {int? id}) async {
    await run(() async {
      if (id == null) {
        await api.createAdminProduct(body);
      } else {
        await api.updateAdminProduct(id, body);
      }
      products = await api.getAdminProducts();
    });
    return error == null;
  }

  Future<bool> deleteProduct(int id) async {
    await run(() async {
      await api.deleteAdminProduct(id);
      products = await api.getAdminProducts();
    });
    return error == null;
  }

  Future<bool> updateAvailability(
      int id, int unitInStock, bool isAvailable) async {
    await run(() async {
      await api.updateProductAvailability(id, unitInStock, isAvailable);
      products = await api.getAdminProducts();
    });
    return error == null;
  }

  Future<bool> saveCategory(Map<String, dynamic> body, {int? id}) async {
    await run(() async {
      if (id == null) {
        await api.createAdminCategory(body);
      } else {
        await api.updateAdminCategory(id, body);
      }
      categories = await api.getAdminCategories();
    });
    return error == null;
  }

  Future<bool> deleteCategory(int id) async {
    await run(() async {
      await api.deleteAdminCategory(id);
      categories = await api.getAdminCategories();
    });
    return error == null;
  }
}

/// Quản lý mèo (Admin CRUD, Staff chỉ đổi trạng thái).
class AdminCatProvider extends LoadableProvider {
  AdminCatProvider(this.api);
  final ApiService api;
  List<Cat> cats = [];
  String search = '';

  Future<void> load() async => run(() async {
        cats = await api.getAdminCats(
            search: search.trim().isEmpty ? null : search.trim());
      });

  Future<bool> saveCat(Map<String, dynamic> body, {int? id}) async {
    await run(() async {
      if (id == null) {
        await api.createAdminCat(body);
      } else {
        await api.updateAdminCat(id, body);
      }
      cats = await api.getAdminCats();
    });
    return error == null;
  }

  Future<bool> deleteCat(int id) async {
    await run(() async {
      await api.deleteAdminCat(id);
      cats = await api.getAdminCats();
    });
    return error == null;
  }

  Future<bool> updateStatus(int id, int statusId) async {
    await run(() async {
      await api.updateCatStatus(id, statusId);
      cats = await api.getAdminCats();
    });
    return error == null;
  }
}

/// Quản lý bàn (Admin CRUD, Staff chỉ đổi trạng thái).
class AdminTableProvider extends LoadableProvider {
  AdminTableProvider(this.api);
  final ApiService api;
  List<CafeTable> tables = [];

  Future<void> load() async => run(() async {
        tables = await api.getAdminTables();
      });

  Future<bool> saveTable(Map<String, dynamic> body, {int? id}) async {
    await run(() async {
      if (id == null) {
        await api.createAdminTable(body);
      } else {
        await api.updateAdminTable(id, body);
      }
      tables = await api.getAdminTables();
    });
    return error == null;
  }

  Future<bool> deleteTable(int id) async {
    await run(() async {
      await api.deleteAdminTable(id);
      tables = await api.getAdminTables();
    });
    return error == null;
  }

  Future<bool> updateStatus(int id, int tableStatusId) async {
    await run(() async {
      await api.updateTableStatus(id, tableStatusId);
      tables = await api.getAdminTables();
    });
    return error == null;
  }
}

/// Danh sách đơn hàng cho Staff/Admin + cập nhật trạng thái + lọc.
class StaffOrderProvider extends LoadableProvider {
  StaffOrderProvider(this.api);
  final ApiService api;
  List<Order> orders = [];
  Order? selectedOrder;
  int? statusFilter;
  String? dateFilter;

  Future<void> load() async => run(() async {
        orders =
            await api.getStaffOrders(statusId: statusFilter, date: dateFilter);
      });

  Future<void> applyFilters({int? statusId, String? date}) async {
    statusFilter = statusId;
    dateFilter = date;
    await load();
  }

  Future<Order?> loadOrderDetail(int id) async {
    await run(() async {
      selectedOrder = await api.getStaffOrder(id);
    });
    return selectedOrder;
  }

  Future<bool> updateStatus(int id, int statusId) async {
    await run(() async {
      await api.updateOrderStatus(id, statusId);
      orders =
          await api.getStaffOrders(statusId: statusFilter, date: dateFilter);
      if (selectedOrder?.orderId == id) {
        selectedOrder = await api.getStaffOrder(id);
      }
    });
    return error == null;
  }
}

/// Danh sách đặt bàn cho Staff/Admin + cập nhật trạng thái + lọc.
class StaffReservationProvider extends LoadableProvider {
  StaffReservationProvider(this.api);
  final ApiService api;
  List<Reservation> reservations = [];
  int? statusFilter;
  String? dateFilter;

  Future<void> load() async => run(() async {
        reservations = await api.getStaffReservations(
            statusId: statusFilter, date: dateFilter);
      });

  Future<void> applyFilters({int? statusId, String? date}) async {
    statusFilter = statusId;
    dateFilter = date;
    await load();
  }

  Future<bool> updateStatus(int id, int statusId) async {
    await run(() async {
      await api.updateReservationStatus(id, statusId);
      reservations = await api.getStaffReservations(
          statusId: statusFilter, date: dateFilter);
    });
    return error == null;
  }
}

/// Quản lý người dùng (Admin-only): danh sách, tạo Staff, đổi vai trò, kích hoạt.
class AdminUserProvider extends LoadableProvider {
  AdminUserProvider(this.api);
  final ApiService api;
  List<AdminUser> users = [];
  int? roleFilter;
  bool? activeFilter;
  String search = '';

  Future<void> load() async => run(() async {
        users = await api.getAdminUsers(
          roleId: roleFilter,
          search: search.trim().isEmpty ? null : search.trim(),
          active: activeFilter,
        );
      });

  Future<void> applyFilters({int? roleId, bool? active, String? keyword}) async {
    roleFilter = roleId;
    activeFilter = active;
    search = keyword ?? search;
    await load();
  }

  Future<bool> createStaff(Map<String, dynamic> body) async {
    await run(() async {
      await api.createStaff(body);
      await _reload();
    });
    return error == null;
  }

  Future<bool> updateRole(int id, int roleId) async {
    await run(() async {
      await api.updateUserRole(id, roleId);
      await _reload();
    });
    return error == null;
  }

  Future<bool> updateActive(int id, bool isActive) async {
    await run(() async {
      await api.updateUserActive(id, isActive);
      await _reload();
    });
    return error == null;
  }

  Future<void> _reload() async {
    users = await api.getAdminUsers(
      roleId: roleFilter,
      search: search.trim().isEmpty ? null : search.trim(),
      active: activeFilter,
    );
  }
}

/// Tổng hợp số liệu Dashboard từ các endpoint danh sách sẵn có (không có
/// endpoint summary riêng - theo Open Decision của plan). Dùng các endpoint mà
/// cả Admin lẫn Staff đều gọi được để tránh lỗi 403.
class DashboardProvider extends LoadableProvider {
  DashboardProvider(this.api);
  final ApiService api;

  int pendingOrders = 0;
  int todayReservations = 0;
  int lowStockProducts = 0;
  int catsNotWorking = 0;

  Future<void> load() async => run(() async {
        final today = DateTime.now();
        final dateStr =
            '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        final orders = await api.getStaffOrders();
        final reservations = await api.getStaffReservations(date: dateStr);
        final products = await api.getProducts();
        final cats = await api.getCats();

        pendingOrders =
            orders.where((order) => order.statusName == 'Đang chờ').length;
        todayReservations = reservations.length;
        lowStockProducts = products
            .where((product) => product.unitInStock <= kLowStockThreshold)
            .length;
        catsNotWorking =
            cats.where((cat) => cat.statusName != 'Đang làm việc').length;
      });
}

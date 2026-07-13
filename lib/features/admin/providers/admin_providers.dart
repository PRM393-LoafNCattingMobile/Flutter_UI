import 'dart:math' as math;

import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

/// Ngưỡng tồn kho thấp dùng cho thẻ cảnh báo ở Dashboard.
const int kLowStockThreshold = 5;
const String kPendingOrderStatusName = '\u0110ang ch\u1edd';
const String kWorkingCatStatusName = '\u0110ang l\u00e0m vi\u1ec7c';

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
  final List<Product> _products = [];
  List<Category> categories = [];
  String search = '';
  int? selectedCategoryId;
  ProductAvailabilityFilter availabilityFilter = ProductAvailabilityFilter.all;
  double _minPrice = 0;
  double? _maxPrice;
  ProductSortOption sortOption = ProductSortOption.defaultOrder;
  bool discountedOnly = false;
  bool lowStockOnly = false;

  static const double _priceStep = 10000;
  static const double _minimumPriceCeiling = 100000;

  double get priceFilterFloor => 0;

  double get priceFilterCeiling {
    if (_products.isEmpty) {
      return _minimumPriceCeiling;
    }

    final highestPrice = _products
        .map((product) => product.displayPrice)
        .fold<double>(0, math.max);
    final roundedCeiling = (highestPrice / _priceStep).ceil() * _priceStep;
    return math.max(_minimumPriceCeiling, roundedCeiling.toDouble());
  }

  double get _rawClampedMinPrice => _clampPrice(_minPrice);
  double get _rawClampedMaxPrice =>
      _clampPrice(_maxPrice ?? priceFilterCeiling);

  double get priceFilterMin =>
      math.min(_rawClampedMinPrice, _rawClampedMaxPrice);
  double get priceFilterMax =>
      math.max(_rawClampedMinPrice, _rawClampedMaxPrice);

  bool get hasPriceFilter =>
      priceFilterMin > priceFilterFloor || priceFilterMax < priceFilterCeiling;

  bool get hasProductFilters =>
      search.trim().isNotEmpty ||
      selectedCategoryId != null ||
      availabilityFilter != ProductAvailabilityFilter.all ||
      hasPriceFilter ||
      sortOption != ProductSortOption.defaultOrder ||
      discountedOnly ||
      lowStockOnly;

  List<Product> get products {
    Iterable<Product> filtered = _products;

    final keyword = search.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(keyword) ||
            product.categoryName.toLowerCase().contains(keyword) ||
            (product.description?.toLowerCase().contains(keyword) ?? false);
      });
    }

    final categoryId = selectedCategoryId;
    if (categoryId != null) {
      filtered = filtered.where((product) => product.categoryId == categoryId);
    }

    if (availabilityFilter == ProductAvailabilityFilter.availableOnly) {
      filtered = filtered
          .where((product) => product.isAvailable && product.unitInStock > 0);
    }

    final minPrice = priceFilterMin;
    final maxPrice = priceFilterMax;
    filtered = filtered.where((product) {
      final price = product.displayPrice;
      return price >= minPrice && price <= maxPrice;
    });

    if (discountedOnly) {
      filtered = filtered.where((product) => product.discountPrice != null);
    }

    if (lowStockOnly) {
      filtered = filtered
          .where((product) => product.unitInStock <= kLowStockThreshold);
    }

    final items = filtered.toList();
    switch (sortOption) {
      case ProductSortOption.defaultOrder:
        break;
      case ProductSortOption.nameAZ:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProductSortOption.priceLowHigh:
        items.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        break;
      case ProductSortOption.priceHighLow:
        items.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
        break;
    }
    return items;
  }

  Future<void> load() async => run(() async {
        categories = await api.getAdminCategories();
        await _reloadProducts();
      });

  void applySearch(String keyword) {
    search = keyword;
    notifyListeners();
  }

  void applyCategoryFilter(int? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  void applyMenuFilters({
    required ProductAvailabilityFilter availability,
    required double minPrice,
    required double maxPrice,
    required ProductSortOption sortOption,
    required bool discountedOnly,
    required bool lowStockOnly,
  }) {
    availabilityFilter = availability;
    final nextMin = _clampPrice(_snapPrice(minPrice));
    final nextMax = _clampPrice(_snapPrice(maxPrice));
    _minPrice = math.min(nextMin, nextMax);
    final resolvedMax = math.max(nextMin, nextMax);
    _maxPrice = resolvedMax >= priceFilterCeiling ? null : resolvedMax;
    this.sortOption = sortOption;
    this.discountedOnly = discountedOnly;
    this.lowStockOnly = lowStockOnly;
    notifyListeners();
  }

  void resetProductFilters() {
    search = '';
    selectedCategoryId = null;
    availabilityFilter = ProductAvailabilityFilter.all;
    _minPrice = priceFilterFloor;
    _maxPrice = null;
    sortOption = ProductSortOption.defaultOrder;
    discountedOnly = false;
    lowStockOnly = false;
    notifyListeners();
  }

  void clearSearchFilter() {
    search = '';
    notifyListeners();
  }

  void clearCategoryFilter() {
    selectedCategoryId = null;
    notifyListeners();
  }

  void clearAvailabilityFilter() {
    availabilityFilter = ProductAvailabilityFilter.all;
    notifyListeners();
  }

  void clearPriceRangeFilter() {
    _minPrice = priceFilterFloor;
    _maxPrice = null;
    notifyListeners();
  }

  void clearSortFilter() {
    sortOption = ProductSortOption.defaultOrder;
    notifyListeners();
  }

  void clearDiscountFilter() {
    discountedOnly = false;
    notifyListeners();
  }

  void clearLowStockFilter() {
    lowStockOnly = false;
    notifyListeners();
  }

  void showLowStockProducts() {
    search = '';
    selectedCategoryId = null;
    availabilityFilter = ProductAvailabilityFilter.all;
    _minPrice = priceFilterFloor;
    _maxPrice = null;
    sortOption = ProductSortOption.defaultOrder;
    discountedOnly = false;
    lowStockOnly = true;
    notifyListeners();
  }

  Future<bool> saveProduct(Map<String, dynamic> body, {int? id}) async {
    await run(() async {
      if (id == null) {
        await api.createAdminProduct(body);
      } else {
        await api.updateAdminProduct(id, body);
      }
      await _reloadProducts();
    });
    return error == null;
  }

  Future<bool> deleteProduct(int id) async {
    await run(() async {
      await api.deleteAdminProduct(id);
      await _reloadProducts();
    });
    return error == null;
  }

  Future<bool> updateAvailability(
      int id, int unitInStock, bool isAvailable) async {
    await run(() async {
      await api.updateProductAvailability(id, unitInStock, isAvailable);
      await _reloadProducts();
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

  Future<void> _reloadProducts() async {
    _products
      ..clear()
      ..addAll(await api.getAdminProducts());
  }

  double _clampPrice(double price) =>
      price.clamp(priceFilterFloor, priceFilterCeiling).toDouble();

  double _snapPrice(double price) => (price / _priceStep).round() * _priceStep;
}

/// Quản lý mèo (Admin CRUD, Staff chỉ đổi trạng thái).
class AdminCatProvider extends LoadableProvider {
  AdminCatProvider(this.api);
  final ApiService api;
  final List<Cat> _cats = [];
  String search = '';
  String? statusFilterName;
  String? genderFilterName;
  bool notWorkingOnly = false;

  bool get hasCatFilters =>
      search.trim().isNotEmpty ||
      statusFilterName != null ||
      genderFilterName != null ||
      notWorkingOnly;

  List<Cat> get cats {
    Iterable<Cat> filtered = _cats;

    final keyword = search.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      filtered = filtered.where((cat) {
        return cat.name.toLowerCase().contains(keyword) ||
            (cat.breed?.toLowerCase().contains(keyword) ?? false) ||
            (cat.description?.toLowerCase().contains(keyword) ?? false) ||
            cat.statusName.toLowerCase().contains(keyword) ||
            (cat.genderName?.toLowerCase().contains(keyword) ?? false);
      });
    }

    final statusName = statusFilterName;
    if (statusName != null) {
      filtered = filtered.where((cat) => cat.statusName == statusName);
    }

    final genderName = genderFilterName;
    if (genderName != null) {
      filtered = filtered.where((cat) => cat.genderName == genderName);
    }

    if (notWorkingOnly) {
      filtered =
          filtered.where((cat) => cat.statusName != kWorkingCatStatusName);
    }

    return filtered.toList();
  }

  Future<void> load() async => run(() async {
        await _reloadCats();
      });

  void applySearch(String keyword) {
    search = keyword;
    notifyListeners();
  }

  void applyStatusFilter(String? statusName) {
    statusFilterName = statusName;
    notifyListeners();
  }

  void applyGenderFilter(String? genderName) {
    genderFilterName = genderName;
    notifyListeners();
  }

  void applyNotWorkingFilter(bool value) {
    notWorkingOnly = value;
    notifyListeners();
  }

  void resetCatFilters() {
    search = '';
    statusFilterName = null;
    genderFilterName = null;
    notWorkingOnly = false;
    notifyListeners();
  }

  void clearSearchFilter() {
    search = '';
    notifyListeners();
  }

  void clearNotWorkingFilter() {
    notWorkingOnly = false;
    notifyListeners();
  }

  void showNotWorkingCats() {
    search = '';
    statusFilterName = null;
    genderFilterName = null;
    notWorkingOnly = true;
    notifyListeners();
  }

  Future<bool> saveCat(Map<String, dynamic> body, {int? id}) async {
    await run(() async {
      if (id == null) {
        await api.createAdminCat(body);
      } else {
        await api.updateAdminCat(id, body);
      }
      await _reloadCats();
    });
    return error == null;
  }

  Future<bool> deleteCat(int id) async {
    await run(() async {
      await api.deleteAdminCat(id);
      await _reloadCats();
    });
    return error == null;
  }

  Future<bool> updateStatus(int id, int statusId) async {
    await run(() async {
      await api.updateCatStatus(id, statusId);
      await _reloadCats();
    });
    return error == null;
  }

  Future<void> _reloadCats() async {
    _cats
      ..clear()
      ..addAll(await api.getAdminCats());
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

  bool get hasFilters => statusFilter != null || dateFilter != null;

  Future<void> load() async => run(() async {
        orders =
            await api.getStaffOrders(statusId: statusFilter, date: dateFilter);
      });

  Future<void> applyFilters({int? statusId, String? date}) async {
    statusFilter = statusId;
    dateFilter = date;
    await load();
  }

  Future<void> applyStatusFilter(int? statusId) async {
    statusFilter = statusId;
    await load();
  }

  Future<void> applyDateFilter(String? date) async {
    dateFilter = date;
    await load();
  }

  Future<void> clearFilters() async {
    statusFilter = null;
    dateFilter = null;
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

  bool get hasFilters => statusFilter != null || dateFilter != null;

  Future<void> load() async => run(() async {
        reservations = await api.getStaffReservations(
            statusId: statusFilter, date: dateFilter);
      });

  Future<void> applyFilters({int? statusId, String? date}) async {
    statusFilter = statusId;
    dateFilter = date;
    await load();
  }

  Future<void> applyStatusFilter(int? statusId) async {
    statusFilter = statusId;
    await load();
  }

  Future<void> applyDateFilter(String? date) async {
    dateFilter = date;
    await load();
  }

  Future<void> clearFilters() async {
    statusFilter = null;
    dateFilter = null;
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

  Future<void> applyFilters(
      {int? roleId, bool? active, String? keyword}) async {
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

        pendingOrders = orders
            .where((order) => order.statusName == kPendingOrderStatusName)
            .length;
        todayReservations = reservations.length;
        lowStockProducts = products
            .where((product) => product.unitInStock <= kLowStockThreshold)
            .length;
        catsNotWorking =
            cats.where((cat) => cat.statusName != kWorkingCatStatusName).length;
      });
}

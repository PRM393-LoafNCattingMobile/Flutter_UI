import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

const pendingStatus = '\u0110ang ch\u1edd';
const completeStatus = 'Ho\u00e0n th\u00e0nh';
const preparingStatus = '\u0110ang chu\u1ea9n b\u1ecb';
const paidStatus = '\u0110\u00e3 thanh to\u00e1n';
const maleGender = '\u0110\u1ef1c';
const workingCatStatus = '\u0110ang l\u00e0m vi\u1ec7c';
const sickCatStatus = 'B\u1ecb b\u1ec7nh';

Order _order(int id, String status) => Order.fromJson({
      'orderId': id,
      'orderDate': '2026-06-30T10:00:00',
      'totalPrice': 50000,
      'customerUserId': 1,
      'statusName': status,
      'paymentStatus': paidStatus,
      'items': const [],
      'customerName': 'Khach $id',
    });

Reservation _reservation(int id) => Reservation.fromJson({
      'reservationId': id,
      'userId': 1,
      'date': '2026-06-30',
      'time': '10:00:00',
      'guestName': 'Khach',
      'guestPhoneNumber': '0900000000',
      'numberOfGuests': 2,
      'note': null,
      'statusName': pendingStatus,
      'tableId': 1,
      'tableName': 'Ban 1',
    });

Product _product(int id, int stock) => Product.fromJson({
      'productId': id,
      'name': 'Mon $id',
      'description': null,
      'price': 20000,
      'discountPrice': null,
      'unitInStock': stock,
      'picture': null,
      'categoryId': 1,
      'categoryName': 'Ca phe',
      'isAvailable': true,
      'canOrder': true,
    });

Cat _cat(int id, String status) => Cat.fromJson({
      'catId': id,
      'name': 'Meo $id',
      'age': 2,
      'genderName': maleGender,
      'breed': null,
      'picture': null,
      'description': null,
      'friendlinessRating': 5,
      'cutenessRating': 5,
      'playfulnessRating': 5,
      'statusName': status,
    });

class _FakeApi extends ApiService {
  int updateOrderCalls = 0;
  int? lastOrderStatusId;
  String? lastOrderDate;
  int? lastReservationStatusId;
  String? lastReservationDate;

  @override
  Future<List<Order>> getStaffOrders({int? statusId, String? date}) async {
    lastOrderStatusId = statusId;
    lastOrderDate = date;
    return [
      _order(1, pendingStatus),
      _order(2, pendingStatus),
      _order(3, completeStatus),
    ];
  }

  @override
  Future<Order> updateOrderStatus(int id, int statusId) async {
    updateOrderCalls++;
    return _order(id, preparingStatus);
  }

  @override
  Future<List<Reservation>> getStaffReservations(
      {int? statusId, String? date}) async {
    lastReservationStatusId = statusId;
    lastReservationDate = date;
    return [_reservation(1)];
  }

  @override
  Future<List<Product>> getProducts({int? categoryId, String? search}) async =>
      [_product(1, 2), _product(2, 10), _product(3, 0)];

  @override
  Future<List<Category>> getAdminCategories() async =>
      [Category(categoryId: 1, name: 'Ca phe')];

  @override
  Future<List<Product>> getAdminProducts(
          {int? categoryId, String? search}) async =>
      [_product(1, 2), _product(2, 10), _product(3, 0)];

  @override
  Future<List<Cat>> getCats({String? search}) async =>
      [_cat(1, workingCatStatus), _cat(2, sickCatStatus)];

  @override
  Future<List<Cat>> getAdminCats({String? search}) async =>
      [_cat(1, workingCatStatus), _cat(2, sickCatStatus)];
}

void main() {
  test('StaffOrderProvider loads orders', () async {
    final provider = StaffOrderProvider(_FakeApi());
    await provider.load();

    expect(provider.error, isNull);
    expect(provider.orders, hasLength(3));
  });

  test('StaffOrderProvider.updateStatus calls the API then reloads', () async {
    final api = _FakeApi();
    final provider = StaffOrderProvider(api);

    await provider.applyStatusFilter(1);
    await provider.applyDateFilter('2026-07-13');
    final ok = await provider.updateStatus(1, 2);

    expect(ok, isTrue);
    expect(api.updateOrderCalls, 1);
    expect(api.lastOrderStatusId, 1);
    expect(api.lastOrderDate, '2026-07-13');
    expect(provider.orders, hasLength(3));
  });

  test('StaffOrderProvider keeps status and date filters independently',
      () async {
    final api = _FakeApi();
    final provider = StaffOrderProvider(api);

    await provider.applyStatusFilter(2);
    await provider.applyDateFilter('2026-07-13');

    expect(provider.statusFilter, 2);
    expect(provider.dateFilter, '2026-07-13');
    expect(api.lastOrderStatusId, 2);
    expect(api.lastOrderDate, '2026-07-13');

    await provider.applyStatusFilter(null);

    expect(provider.statusFilter, isNull);
    expect(provider.dateFilter, '2026-07-13');
    expect(api.lastOrderStatusId, isNull);
    expect(api.lastOrderDate, '2026-07-13');
  });

  test('StaffReservationProvider sends date filter with status filter',
      () async {
    final api = _FakeApi();
    final provider = StaffReservationProvider(api);

    await provider.applyStatusFilter(3);
    await provider.applyDateFilter('2026-07-14');

    expect(provider.statusFilter, 3);
    expect(provider.dateFilter, '2026-07-14');
    expect(api.lastReservationStatusId, 3);
    expect(api.lastReservationDate, '2026-07-14');

    await provider.clearFilters();

    expect(provider.statusFilter, isNull);
    expect(provider.dateFilter, isNull);
    expect(api.lastReservationStatusId, isNull);
    expect(api.lastReservationDate, isNull);
  });

  test('DashboardProvider computes operational counts', () async {
    final provider = DashboardProvider(_FakeApi());
    await provider.load();

    expect(provider.error, isNull);
    expect(provider.pendingOrders, 2);
    expect(provider.todayReservations, 1);
    expect(provider.lowStockProducts, 2);
    expect(provider.catsNotWorking, 1);
  });

  test('AdminCatalogProvider can show dashboard low-stock filter', () async {
    final provider = AdminCatalogProvider(_FakeApi());
    await provider.load();

    provider.showLowStockProducts();

    expect(provider.lowStockOnly, isTrue);
    expect(provider.hasProductFilters, isTrue);
    expect(provider.products.map((product) => product.productId), [1, 3]);
  });

  test('AdminCatProvider can show dashboard not-working filter', () async {
    final provider = AdminCatProvider(_FakeApi());
    await provider.load();

    provider.showNotWorkingCats();

    expect(provider.notWorkingOnly, isTrue);
    expect(provider.hasCatFilters, isTrue);
    expect(provider.cats.map((cat) => cat.catId), [2]);
  });
}

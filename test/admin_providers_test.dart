import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

Order _order(int id, String status) => Order.fromJson({
      'orderId': id,
      'orderDate': '2026-06-30T10:00:00',
      'totalPrice': 50000,
      'customerUserId': 1,
      'statusName': status,
      'paymentStatus': 'Đã thanh toán',
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
      'statusName': 'Đang chờ',
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
      'genderName': 'Đực',
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

  @override
  Future<List<Order>> getStaffOrders({int? statusId, String? date}) async => [
        _order(1, 'Đang chờ'),
        _order(2, 'Đang chờ'),
        _order(3, 'Hoàn thành'),
      ];

  @override
  Future<Order> updateOrderStatus(int id, int statusId) async {
    updateOrderCalls++;
    return _order(id, 'Đang chuẩn bị');
  }

  @override
  Future<List<Reservation>> getStaffReservations(
          {int? statusId, String? date}) async =>
      [_reservation(1)];

  @override
  Future<List<Product>> getProducts({int? categoryId, String? search}) async =>
      [_product(1, 2), _product(2, 10), _product(3, 0)];

  @override
  Future<List<Cat>> getCats({String? search}) async =>
      [_cat(1, 'Đang làm việc'), _cat(2, 'Bị bệnh')];
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

    final ok = await provider.updateStatus(1, 2);

    expect(ok, isTrue);
    expect(api.updateOrderCalls, 1);
    expect(provider.orders, hasLength(3));
  });

  test('DashboardProvider computes operational counts', () async {
    final provider = DashboardProvider(_FakeApi());
    await provider.load();

    expect(provider.error, isNull);
    expect(provider.pendingOrders, 2); // two "Đang chờ"
    expect(provider.todayReservations, 1);
    expect(provider.lowStockProducts, 2); // stock 2 and 0 are <= threshold 5
    expect(provider.catsNotWorking, 1); // one "Bị bệnh"
  });
}

// Models cho khu vực Admin/Staff. Tái dùng `Product`, `Cat`, `CafeTable`,
// `Category`, `Reservation` từ `models/models.dart`; ở đây chỉ bổ sung các
// model mà luồng vận hành admin/staff cần thêm.

class OrderDetail {
  OrderDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
      );
}

class Order {
  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalPrice,
    this.customerUserId,
    required this.statusName,
    required this.paymentStatus,
    required this.items,
    this.customerName,
  });

  final int orderId;
  final DateTime orderDate;
  final double totalPrice;
  final int? customerUserId;
  final String statusName;
  final String paymentStatus;
  final List<OrderDetail> items;
  final String? customerName;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json['orderId'],
        orderDate: DateTime.parse(json['orderDate']),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        customerUserId: json['customerUserId'],
        statusName: json['statusName'],
        paymentStatus: json['paymentStatus'],
        items: (json['items'] as List? ?? [])
            .map((item) => OrderDetail.fromJson(item))
            .toList(),
        customerName: json['customerName'],
      );
}

class AdminUser {
  AdminUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.avatarUrl,
    this.avatarKey,
    required this.roleId,
    required this.roleName,
    required this.isActive,
    required this.isEmailVerified,
    required this.createdAt,
    this.updatedAt,
  });

  final int userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? address;
  final String? avatarUrl;
  final String? avatarKey;
  final int roleId;
  final String roleName;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        address: json['address'],
        avatarUrl: json['avatarUrl'],
        avatarKey: json['avatarKey'],
        roleId: json['roleId'],
        roleName: json['roleName'],
        isActive: json['isActive'],
        isEmailVerified: json['isEmailVerified'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt']),
      );
}

class LookupItem {
  LookupItem({required this.id, required this.name, this.description});

  final int id;
  final String name;
  final String? description;

  factory LookupItem.fromJson(Map<String, dynamic> json) => LookupItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
      );
}

class AdminLookups {
  AdminLookups({
    required this.roles,
    required this.orderStatuses,
    required this.reservationStatuses,
    required this.catStatuses,
    required this.tableStatuses,
    required this.paymentMethods,
    required this.genders,
    required this.categories,
  });

  final List<LookupItem> roles;
  final List<LookupItem> orderStatuses;
  final List<LookupItem> reservationStatuses;
  final List<LookupItem> catStatuses;
  final List<LookupItem> tableStatuses;
  final List<LookupItem> paymentMethods;
  final List<LookupItem> genders;
  final List<LookupItem> categories;

  static List<LookupItem> _items(dynamic raw) =>
      (raw as List? ?? []).map((item) => LookupItem.fromJson(item)).toList();

  factory AdminLookups.fromJson(Map<String, dynamic> json) => AdminLookups(
        roles: _items(json['roles']),
        orderStatuses: _items(json['orderStatuses']),
        reservationStatuses: _items(json['reservationStatuses']),
        catStatuses: _items(json['catStatuses']),
        tableStatuses: _items(json['tableStatuses']),
        paymentMethods: _items(json['paymentMethods']),
        genders: _items(json['genders']),
        categories: _items(json['categories']),
      );
}

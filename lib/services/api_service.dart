import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loafncatting_mobile/core/api_config.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_chat_models.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, String?> query = const {}]) {
    final cleanQuery = Map.fromEntries(query.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty));
    return Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: cleanQuery.isEmpty ? null : cleanQuery);
  }

  Future<Map<String, String>> _headers({bool json = false}) async {
    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('authUser');
    if (raw != null) {
      final token = AuthUser.fromJson(jsonDecode(raw)).token;
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> _get(String path,
      [Map<String, String?> query = const {}]) async {
    final response =
        await _client.get(_uri(path, query), headers: await _headers());
    return _decode(response);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(_uri(path),
        headers: await _headers(json: true), body: jsonEncode(body));
    return _decode(response);
  }

  Future<dynamic> _put(String path, [Map<String, dynamic>? body]) async {
    final response = await _client.put(
      _uri(path),
      headers: await _headers(json: body != null),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> _delete(String path) async {
    final response =
        await _client.delete(_uri(path), headers: await _headers());
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final decodedBody = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 400) {
      final message = _extractErrorMessage(decodedBody);
      throw ApiException(
        message ?? 'Yêu cầu thất bại',
        statusCode: response.statusCode,
      );
    }
    if (decodedBody.isEmpty) {
      return null;
    }
    return jsonDecode(decodedBody);
  }

  String? _extractErrorMessage(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {
      // Fall through and return the raw body for non-JSON errors.
    }

    return body;
  }

  Future<AuthUser> login(String login, String password) async {
    final data =
        await _post('/auth/login', {'login': login, 'password': password});
    return AuthUser.fromJson(data);
  }

  Future<EmailVerificationChallenge> register(
      String name, String email, String phoneNumber, String password) async {
    final data = await _post('/auth/register', {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    });
    return EmailVerificationChallenge.fromJson(data);
  }

  Future<AuthUser> verifyEmail(String email, String verificationCode) async {
    final data = await _post('/auth/verify-email', {
      'email': email,
      'verificationCode': verificationCode,
    });
    return AuthUser.fromJson(data);
  }

  Future<EmailVerificationChallenge> resendVerification(String email) async {
    final data = await _post('/auth/resend-verification', {
      'email': email,
    });
    return EmailVerificationChallenge.fromJson(data);
  }

  Future<void> logout() async {
    await _post('/auth/logout', const {});
  }

  Future<List<Category>> getCategories() async {
    final data = await _get('/categories') as List;
    return data.map((item) => Category.fromJson(item)).toList();
  }

  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    final data = await _get('/products',
        {'categoryId': categoryId?.toString(), 'search': search}) as List;
    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<Product> getProduct(int id) async {
    final data = await _get('/products/$id');
    return Product.fromJson(data);
  }

  Future<List<Cat>> getCats({String? search}) async {
    final data = await _get('/cats', {'search': search}) as List;
    return data.map((item) => Cat.fromJson(item)).toList();
  }

  Future<List<CafeTable>> getAvailableTables(
      {required String date,
      required String time,
      required int guestCount}) async {
    final data = await _get('/tables/available', {
      'date': date,
      'time': time,
      'guestCount': guestCount.toString(),
    }) as List;
    return data.map((item) => CafeTable.fromJson(item)).toList();
  }

  Future<Reservation> createReservation(Map<String, dynamic> body) async {
    final data = await _post('/reservations', body);
    return Reservation.fromJson(data);
  }

  Future<List<Reservation>> getReservations(int userId) async {
    final data = await _get('/reservations/user/$userId') as List;
    return data.map((item) => Reservation.fromJson(item)).toList();
  }

  /// Trả về OrderDto vừa tạo (cần orderId để tạo link thanh toán PayOS).
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    final data = await _post('/orders', body);
    return data as Map<String, dynamic>;
  }

  Future<List<CartItem>> getCart(int userId) async {
    final data = await _get('/carts/user/$userId');
    return _cartItemsFromResponse(data);
  }

  Future<List<CartItem>> addCartItem(
      int userId, int productId, int quantity) async {
    final data = await _post('/carts/items', {
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
    });
    return _cartItemsFromResponse(data);
  }

  Future<List<CartItem>> updateCartItem(
      int userId, int productId, int quantity) async {
    final data = await _put('/carts/items', {
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
    });
    return _cartItemsFromResponse(data);
  }

  Future<List<CartItem>> removeCartItem(int userId, int productId) async {
    final data = await _delete('/carts/user/$userId/items/$productId');
    return _cartItemsFromResponse(data);
  }

  Future<List<CartItem>> clearCart(int userId) async {
    final data = await _delete('/carts/user/$userId');
    return _cartItemsFromResponse(data);
  }

  /// Tạo link/QR thanh toán PayOS cho đơn đang chờ thanh toán.
  Future<Map<String, dynamic>> createPaymentLink(int orderId) async {
    final data = await _post('/payments/create-link', {'orderId': orderId});
    return data as Map<String, dynamic>;
  }

  /// Poll trạng thái thanh toán của đơn (isPaid == true khi PayOS báo đã trả).
  Future<Map<String, dynamic>> getPaymentStatus(int orderId) async {
    final data = await _get('/payments/status/$orderId');
    return data as Map<String, dynamic>;
  }

  Future<List<AppNotification>> getNotifications(int userId) async {
    final data = await _get('/notifications/user/$userId') as List;
    return data.map((item) => AppNotification.fromJson(item)).toList();
  }

  Future<void> markNotificationRead(int id) async {
    await _put('/notifications/$id/read');
  }

  Future<StoreLocation> getStoreLocation() async {
    final data = await _get('/store-location');
    return StoreLocation.fromJson(data);
  }

  Future<Conversation> getConversation(int userId) async {
    final data = await _get('/conversations/user/$userId');
    return Conversation.fromJson(data);
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final data = await _get('/messages/conversation/$conversationId') as List;
    return data.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<List<ChatMessage>> sendMessage(
      int conversationId, int senderUserId, String content) async {
    final data = await _post('/messages', {
      'conversationId': conversationId,
      'senderUserId': senderUserId,
      'content': content,
    }) as List;
    return data.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<List<AdminConversationSummary>> getAdminConversations() async {
    final data = await _get('/staff/conversations') as List;
    return data
        .map((item) =>
            AdminConversationSummary.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<ChatMessage>> getAdminConversationMessages(int conversationId) async {
    final data = await _get('/staff/conversations/$conversationId/messages') as List;
    return data.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<List<ChatMessage>> sendAdminMessage(
      int conversationId, String content) async {
    final data = await _post('/staff/conversations/$conversationId/messages', {
      'content': content,
    }) as List;
    return data.map((item) => ChatMessage.fromJson(item)).toList();
  }

  List<CartItem> _cartItemsFromResponse(dynamic data) {
    final items = (data as Map<String, dynamic>)['items'] as List;
    return items
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ========== Lookups (Admin/Staff) ==========
  Future<AdminLookups> getAdminLookups() async {
    final data = await _get('/lookups/admin');
    return AdminLookups.fromJson(data);
  }

  // ========== Admin: Products ==========
  Future<List<Product>> getAdminProducts({int? categoryId, String? search}) async {
    final data = await _get('/admin/products', {
      'categoryId': categoryId?.toString(),
      'search': search,
    }) as List;
    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<Product> getAdminProduct(int id) async {
    final data = await _get('/admin/products/$id');
    return Product.fromJson(data);
  }

  Future<Product> createAdminProduct(Map<String, dynamic> body) async {
    final data = await _post('/admin/products', body);
    return Product.fromJson(data);
  }

  Future<Product> updateAdminProduct(int id, Map<String, dynamic> body) async {
    final data = await _put('/admin/products/$id', body);
    return Product.fromJson(data);
  }

  Future<void> deleteAdminProduct(int id) async {
    await _delete('/admin/products/$id');
  }

  // ========== Staff/Admin: product availability ==========
  Future<Product> updateProductAvailability(
      int id, int unitInStock, bool isAvailable) async {
    final data = await _put('/staff/products/$id/availability', {
      'unitInStock': unitInStock,
      'isAvailable': isAvailable,
    });
    return Product.fromJson(data);
  }

  // ========== Admin: Categories ==========
  Future<List<Category>> getAdminCategories() async {
    final data = await _get('/admin/categories') as List;
    return data.map((item) => Category.fromJson(item)).toList();
  }

  Future<Category> createAdminCategory(Map<String, dynamic> body) async {
    final data = await _post('/admin/categories', body);
    return Category.fromJson(data);
  }

  Future<Category> updateAdminCategory(int id, Map<String, dynamic> body) async {
    final data = await _put('/admin/categories/$id', body);
    return Category.fromJson(data);
  }

  Future<void> deleteAdminCategory(int id) async {
    await _delete('/admin/categories/$id');
  }

  // ========== Admin: Cats ==========
  Future<List<Cat>> getAdminCats({String? search}) async {
    final data = await _get('/admin/cats', {'search': search}) as List;
    return data.map((item) => Cat.fromJson(item)).toList();
  }

  Future<Cat> createAdminCat(Map<String, dynamic> body) async {
    final data = await _post('/admin/cats', body);
    return Cat.fromJson(data);
  }

  Future<Cat> updateAdminCat(int id, Map<String, dynamic> body) async {
    final data = await _put('/admin/cats/$id', body);
    return Cat.fromJson(data);
  }

  Future<void> deleteAdminCat(int id) async {
    await _delete('/admin/cats/$id');
  }

  // ========== Staff/Admin: cat status ==========
  Future<Cat> updateCatStatus(int id, int statusId) async {
    final data = await _put('/staff/cats/$id/status', {'statusId': statusId});
    return Cat.fromJson(data);
  }

  // ========== Admin: Tables ==========
  Future<List<CafeTable>> getAdminTables() async {
    final data = await _get('/admin/tables') as List;
    return data.map((item) => CafeTable.fromJson(item)).toList();
  }

  Future<CafeTable> createAdminTable(Map<String, dynamic> body) async {
    final data = await _post('/admin/tables', body);
    return CafeTable.fromJson(data);
  }

  Future<CafeTable> updateAdminTable(int id, Map<String, dynamic> body) async {
    final data = await _put('/admin/tables/$id', body);
    return CafeTable.fromJson(data);
  }

  Future<void> deleteAdminTable(int id) async {
    await _delete('/admin/tables/$id');
  }

  // ========== Staff/Admin: table status ==========
  Future<CafeTable> updateTableStatus(int id, int tableStatusId) async {
    final data = await _put(
        '/staff/tables/$id/status', {'tableStatusId': tableStatusId});
    return CafeTable.fromJson(data);
  }

  // ========== Staff/Admin: Orders ==========
  Future<List<Order>> getStaffOrders({int? statusId, String? date}) async {
    final data = await _get('/staff/orders', {
      'status': statusId?.toString(),
      'date': date,
    }) as List;
    return data.map((item) => Order.fromJson(item)).toList();
  }

  Future<Order> updateOrderStatus(int id, int statusId) async {
    final data = await _put('/staff/orders/$id/status', {'statusId': statusId});
    return Order.fromJson(data);
  }

  // ========== Staff/Admin: Reservations ==========
  Future<List<Reservation>> getStaffReservations(
      {int? statusId, String? date}) async {
    final data = await _get('/staff/reservations', {
      'status': statusId?.toString(),
      'date': date,
    }) as List;
    return data.map((item) => Reservation.fromJson(item)).toList();
  }

  Future<Reservation> updateReservationStatus(int id, int statusId) async {
    final data =
        await _put('/staff/reservations/$id/status', {'statusId': statusId});
    return Reservation.fromJson(data);
  }

  // ========== Admin: Users ==========
  Future<List<AdminUser>> getAdminUsers(
      {int? roleId, String? search, bool? active}) async {
    final data = await _get('/admin/users', {
      'role': roleId?.toString(),
      'search': search,
      'active': active?.toString(),
    }) as List;
    return data.map((item) => AdminUser.fromJson(item)).toList();
  }

  Future<AdminUser> createStaff(Map<String, dynamic> body) async {
    final data = await _post('/admin/users/staff', body);
    return AdminUser.fromJson(data);
  }

  Future<AdminUser> updateUserRole(int id, int roleId) async {
    final data = await _put('/admin/users/$id/role', {'roleId': roleId});
    return AdminUser.fromJson(data);
  }

  Future<AdminUser> updateUserActive(int id, bool isActive) async {
    final data = await _put('/admin/users/$id/active', {'isActive': isActive});
    return AdminUser.fromJson(data);
  }

  // ========== Admin: Store location ==========
  Future<StoreLocation> updateStoreLocation(Map<String, dynamic> body) async {
    final data = await _put('/admin/store-location', body);
    return StoreLocation.fromJson(data);
  }
}

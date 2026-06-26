import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loafncatting_mobile/core/api_config.dart';
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
      headers['Content-Type'] = 'application/json';
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
    if (response.statusCode >= 400) {
      final message = _extractErrorMessage(response.body);
      throw ApiException(
        message ?? 'Yêu cầu thất bại',
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
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

  List<CartItem> _cartItemsFromResponse(dynamic data) {
    final items = (data as Map<String, dynamic>)['items'] as List;
    return items
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

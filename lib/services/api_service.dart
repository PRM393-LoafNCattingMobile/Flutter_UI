import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loafncatting_mobile/core/api_config.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
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

  Future<void> _put(String path) async {
    final response = await _client.put(_uri(path), headers: await _headers());
    if (response.statusCode >= 400) {
      throw ApiException(
          response.body.isEmpty ? 'Request failed' : response.body);
    }
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 400) {
      throw ApiException(
          response.body.isEmpty ? 'Request failed' : response.body);
    }
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }

  Future<AuthUser> login(String login, String password) async {
    final data =
        await _post('/auth/login', {'login': login, 'password': password});
    return AuthUser.fromJson(data);
  }

  Future<AuthUser> register(
      String name, String email, String phoneNumber, String password) async {
    final data = await _post('/auth/register', {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    });
    return AuthUser.fromJson(data);
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

  Future<void> createOrder(Map<String, dynamic> body) async {
    await _post('/orders', body);
  }

  Future<List<AppNotification>> getNotifications(int userId) async {
    final data = await _get('/notifications/user/$userId') as List;
    return data.map((item) => AppNotification.fromJson(item)).toList();
  }

  Future<void> markNotificationRead(int id) => _put('/notifications/$id/read');

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
}

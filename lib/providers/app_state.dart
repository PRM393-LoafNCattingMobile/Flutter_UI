import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadableProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  Future<void> run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class AuthProvider extends LoadableProvider {
  AuthProvider(this.api);
  final ApiService api;
  AuthUser? user;

  bool get isLoggedIn => user != null;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('authUser');
    if (raw != null) {
      user = AuthUser.fromJson(jsonDecode(raw));
    }
    notifyListeners();
  }

  Future<bool> login(String login, String password) async {
    await run(() async {
      user = await api.login(login, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authUser', jsonEncode(user!.toJson()));
    });
    return error == null;
  }

  Future<bool> register(
      String name, String email, String phoneNumber, String password) async {
    await run(() async {
      user = await api.register(name, email, phoneNumber, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authUser', jsonEncode(user!.toJson()));
    });
    return error == null;
  }

  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authUser');
    notifyListeners();
  }
}

class CatalogProvider extends LoadableProvider {
  CatalogProvider(this.api);
  final ApiService api;
  List<Category> categories = [];
  List<Product> products = [];
  int? selectedCategoryId;
  String search = '';

  Future<void> load() async => run(() async {
        categories = await api.getCategories();
        products = await api.getProducts(
            categoryId: selectedCategoryId, search: search);
      });

  Future<void> applyFilter({int? categoryId, String? keyword}) async {
    selectedCategoryId = categoryId;
    search = keyword ?? search;
    await load();
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> items = [];

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  int add(Product product, int quantity) {
    if (!product.isAvailable || product.unitInStock <= 0 || quantity <= 0) {
      return 0;
    }
    final index =
        items.indexWhere((item) => item.product.productId == product.productId);
    final currentQuantity = index >= 0 ? items[index].quantity : 0;
    final nextQuantity =
        math.min(currentQuantity + quantity, product.unitInStock);
    final added = nextQuantity - currentQuantity;
    if (added <= 0) {
      return 0;
    }
    if (index >= 0) {
      items[index].quantity = nextQuantity;
    } else {
      items.add(CartItem(product: product, quantity: nextQuantity));
    }
    notifyListeners();
    return added;
  }

  void update(Product product, int quantity) {
    final index =
        items.indexWhere((item) => item.product.productId == product.productId);
    if (index < 0) return;
    final nextQuantity = math.min(quantity, product.unitInStock);
    if (nextQuantity <= 0) {
      items.removeAt(index);
    } else {
      items[index].quantity = nextQuantity;
    }
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}

class ReservationProvider extends LoadableProvider {
  ReservationProvider(this.api);
  final ApiService api;
  List<CafeTable> availableTables = [];
  List<Reservation> reservations = [];

  Future<void> loadAvailable(String date, String time, int guestCount) async =>
      run(() async {
        availableTables = await api.getAvailableTables(
            date: date, time: time, guestCount: guestCount);
      });

  Future<bool> create(Map<String, dynamic> body) async {
    await run(() async {
      await api.createReservation(body);
    });
    return error == null;
  }

  Future<void> loadHistory(int userId) async => run(() async {
        reservations = await api.getReservations(userId);
      });
}

class CatProvider extends LoadableProvider {
  CatProvider(this.api);
  final ApiService api;
  List<Cat> cats = [];

  Future<void> load({String? search}) async => run(() async {
        cats = await api.getCats(search: search);
      });
}

class NotificationProvider extends LoadableProvider {
  NotificationProvider(this.api);
  final ApiService api;
  List<AppNotification> notifications = [];

  Future<void> load(int userId) async => run(() async {
        notifications = await api.getNotifications(userId);
      });

  Future<void> markRead(int id, int userId) async => run(() async {
        await api.markNotificationRead(id);
        notifications = await api.getNotifications(userId);
      });
}

class LocationProvider extends LoadableProvider {
  LocationProvider(this.api);
  final ApiService api;
  StoreLocation? location;

  Future<void> load() async => run(() async {
        location = await api.getStoreLocation();
      });
}

class ChatProvider extends LoadableProvider {
  ChatProvider(this.api);
  final ApiService api;
  Conversation? conversation;
  List<ChatMessage> messages = [];

  Future<void> load(int userId) async => run(() async {
        conversation = await api.getConversation(userId);
        messages = await api.getMessages(conversation!.conversationId);
      });

  Future<void> send(int userId, String content) async => run(() async {
        conversation ??= await api.getConversation(userId);
        messages = await api.sendMessage(
            conversation!.conversationId, userId, content);
      });
}

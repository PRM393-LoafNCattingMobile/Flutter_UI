import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadableProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  @protected
  void resetLoadState() {
    isLoading = false;
    error = null;
  }

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
  EmailVerificationChallenge? pendingVerification;

  bool get isLoggedIn => user != null;
  bool get isAwaitingEmailVerification => pendingVerification != null;

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
      pendingVerification = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authUser', jsonEncode(user!.toJson()));
    });
    return error == null;
  }

  Future<bool> register(
      String name, String email, String phoneNumber, String password) async {
    await run(() async {
      pendingVerification =
          await api.register(name, email, phoneNumber, password);
      user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authUser');
    });
    return error == null;
  }

  Future<bool> verifyEmail(String verificationCode) async {
    final challenge = pendingVerification;
    if (challenge == null) {
      error = 'Chưa có yêu cầu xác minh email.';
      notifyListeners();
      return false;
    }

    await run(() async {
      user = await api.verifyEmail(challenge.email, verificationCode);
      pendingVerification = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authUser', jsonEncode(user!.toJson()));
    });
    return error == null;
  }

  Future<bool> resendVerification() async {
    final challenge = pendingVerification;
    if (challenge == null) {
      error = 'Chưa có yêu cầu xác minh email.';
      notifyListeners();
      return false;
    }

    await run(() async {
      pendingVerification = await api.resendVerification(challenge.email);
    });
    return error == null;
  }

  Future<void> logout() async {
    try {
      await api.logout();
    } catch (_) {
      // Keep local logout resilient even when the backend is unavailable.
    }
    resetLoadState();
    user = null;
    pendingVerification = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authUser');
    notifyListeners();
  }
}

enum ProductAvailabilityFilter { all, availableOnly }

enum ProductSortOption { defaultOrder, nameAZ, priceLowHigh, priceHighLow }

const double _menuPriceStep = 10000;
const double _minimumMenuPriceCeiling = 100000;

class CatalogProvider extends LoadableProvider {
  CatalogProvider(this.api, {List<Product>? initialProducts})
      : _products = List<Product>.from(initialProducts ?? const []),
        _allProducts = List<Product>.from(initialProducts ?? const []);

  final ApiService api;
  List<Category> categories = [];
  List<Product> _products;
  List<Product> _allProducts;
  int? selectedCategoryId;
  String search = '';
  ProductAvailabilityFilter availabilityFilter = ProductAvailabilityFilter.all;
  double _minPrice = 0;
  double? _maxPrice;
  ProductSortOption sortOption = ProductSortOption.defaultOrder;
  bool discountedOnly = false;

  List<Product> get allProducts => List.unmodifiable(_allProducts);
  double get priceFilterFloor => 0;

  double get priceFilterCeiling {
    final source = _allProducts.isNotEmpty ? _allProducts : _products;
    if (source.isEmpty) {
      return _minimumMenuPriceCeiling;
    }

    final highestPrice = source
        .map((product) => product.displayPrice)
        .fold<double>(0, math.max);
    final roundedCeiling =
        (highestPrice / _menuPriceStep).ceil() * _menuPriceStep;
    return math.max(_minimumMenuPriceCeiling, roundedCeiling.toDouble());
  }

  double get _rawClampedMinPrice => _clampPrice(_minPrice);
  double get _rawClampedMaxPrice =>
      _clampPrice(_maxPrice ?? priceFilterCeiling);

  double get priceFilterMin =>
      math.min(_rawClampedMinPrice, _rawClampedMaxPrice);
  double get priceFilterMax =>
      math.max(_rawClampedMinPrice, _rawClampedMaxPrice);

  bool get hasPriceFilter =>
      priceFilterMin > priceFilterFloor ||
      priceFilterMax < priceFilterCeiling;

  List<Product> get products {
    Iterable<Product> filtered = _products;

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

  bool get hasMenuFilters =>
      availabilityFilter != ProductAvailabilityFilter.all ||
      hasPriceFilter ||
      sortOption != ProductSortOption.defaultOrder ||
      discountedOnly;

  List<String> get activeFilterLabels {
    final labels = <String>[];
    if (availabilityFilter == ProductAvailabilityFilter.availableOnly) {
      labels.add('Còn hàng');
    }
    if (hasPriceFilter) {
      labels.add(_formatCompactMenuPriceRange(
        priceFilterMin,
        priceFilterMax,
      ));
    }
    switch (sortOption) {
      case ProductSortOption.defaultOrder:
        break;
      case ProductSortOption.nameAZ:
        labels.add('Tên A-Z');
        break;
      case ProductSortOption.priceLowHigh:
        labels.add('Giá Thấp - Cao');
        break;
      case ProductSortOption.priceHighLow:
        labels.add('Giá Cao - Thấp');
        break;
    }
    if (discountedOnly) {
      labels.add('Giảm giá');
    }
    return labels;
  }

  Future<void> load() async => run(() async {
        categories = await api.getCategories();
        _products = await api.getProducts(
            categoryId: selectedCategoryId, search: search);
        if (selectedCategoryId == null && search.trim().isEmpty) {
          _allProducts = List<Product>.from(_products);
        }
      });

  Future<void> applyFilter({int? categoryId, String? keyword}) async {
    selectedCategoryId = categoryId;
    search = keyword ?? search;
    await load();
  }

  void applyMenuFilters({
    required ProductAvailabilityFilter availability,
    required double minPrice,
    required double maxPrice,
    required ProductSortOption sortOption,
    required bool discountedOnly,
  }) {
    availabilityFilter = availability;
    final nextMin = _clampPrice(_snapPrice(minPrice));
    final nextMax = _clampPrice(_snapPrice(maxPrice));
    _minPrice = math.min(nextMin, nextMax);
    final resolvedMax = math.max(nextMin, nextMax);
    _maxPrice = resolvedMax >= priceFilterCeiling ? null : resolvedMax;
    this.sortOption = sortOption;
    this.discountedOnly = discountedOnly;
    notifyListeners();
  }

  void resetMenuFilters() {
    availabilityFilter = ProductAvailabilityFilter.all;
    _minPrice = priceFilterFloor;
    _maxPrice = null;
    sortOption = ProductSortOption.defaultOrder;
    discountedOnly = false;
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

  double _clampPrice(double price) =>
      price.clamp(priceFilterFloor, priceFilterCeiling).toDouble();

  double _snapPrice(double price) =>
      (price / _menuPriceStep).round() * _menuPriceStep;
}

String _formatCompactMenuPrice(double price) {
  final rounded = price.round();
  if (rounded % 1000 == 0) {
    return '${rounded ~/ 1000}k';
  }
  return '$rounded VND';
}

String _formatCompactMenuPriceRange(double min, double max) =>
    '${_formatCompactMenuPrice(min)} - ${_formatCompactMenuPrice(max)}';

enum CartAddStatus { added, stockLimit, authRequired, syncFailed }

class CartAddResult {
  const CartAddResult({
    required this.status,
    this.addedQuantity = 0,
    this.message,
  });

  final CartAddStatus status;
  final int addedQuantity;
  final String? message;

  bool get didAdd => status == CartAddStatus.added && addedQuantity > 0;
}

class CartProvider extends ChangeNotifier {
  CartProvider([ApiService? api]) : api = api ?? ApiService();

  final ApiService api;
  final List<CartItem> items = [];
  bool isSyncing = false;
  String? error;
  int? userId;

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  int add(Product product, int quantity) {
    if (!product.canOrder || quantity <= 0) {
      return 0;
    }
    final index = items.indexWhere(
      (item) => item.product.productId == product.productId,
    );
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

  Future<CartAddResult> addWithSyncResult(
      Product product, int quantity, int? userId) async {
    if (userId == null) {
      final addedQuantity = add(product, quantity);
      return CartAddResult(
        status:
            addedQuantity > 0 ? CartAddStatus.added : CartAddStatus.stockLimit,
        addedQuantity: addedQuantity,
      );
    }

    final rollbackItems = _copyItems();
    final previousQuantity = _quantityFor(product.productId);
    final locallyAdded = add(product, quantity);
    if (locallyAdded <= 0) {
      return const CartAddResult(status: CartAddStatus.stockLimit);
    }

    isSyncing = true;
    error = null;
    notifyListeners();
    try {
      final serverItems =
          await api.addCartItem(userId, product.productId, quantity);
      _replaceItems(serverItems, notify: false);
      final addedQuantity =
          math.max(0, _quantityFor(product.productId) - previousQuantity);
      return CartAddResult(
        status:
            addedQuantity > 0 ? CartAddStatus.added : CartAddStatus.stockLimit,
        addedQuantity: addedQuantity,
      );
    } on ApiException catch (e) {
      _replaceItems(rollbackItems, notify: false);
      error = e.toString();
      final status = _statusForCartAddError(e);
      return CartAddResult(status: status, message: e.message);
    } catch (e) {
      _replaceItems(rollbackItems, notify: false);
      error = e.toString();
      return CartAddResult(
        status: CartAddStatus.syncFailed,
        message: e.toString(),
      );
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<int> addSynced(Product product, int quantity, int? userId) async {
    final result = await addWithSyncResult(product, quantity, userId);
    return result.addedQuantity;
  }

  CartAddStatus _statusForCartAddError(ApiException error) {
    if (error.statusCode == 401 || error.statusCode == 403) {
      return CartAddStatus.authRequired;
    }
    if (error.statusCode == 400) {
      return CartAddStatus.stockLimit;
    }
    return CartAddStatus.syncFailed;
  }

  void update(Product product, int quantity) {
    final index =
        items.indexWhere((item) => item.product.productId == product.productId);
    if (index < 0) return;
    updateItem(items[index], quantity);
  }

  void updateItem(CartItem item, int quantity) {
    final index = items.indexOf(item);
    if (index < 0) return;

    final productId = item.product.productId;
    final otherQuantity = items
        .where((cartItem) => cartItem.product.productId == productId)
        .where((cartItem) => cartItem != item)
        .fold(0, (sum, cartItem) => sum + cartItem.quantity);
    final maxQuantity = item.product.unitInStock - otherQuantity;
    final nextQuantity = math.min(quantity, maxQuantity);
    if (nextQuantity <= 0) {
      items.removeAt(index);
    } else {
      items[index].quantity = nextQuantity;
    }
    notifyListeners();
  }

  Future<void> updateSynced(Product product, int quantity, int? userId) async {
    if (userId == null) {
      update(product, quantity);
      return;
    }

    final rollbackItems = _copyItems();
    update(product, quantity);
    await _sync(
      () async {
        final serverItems = quantity <= 0
            ? await api.removeCartItem(userId, product.productId)
            : await api.updateCartItem(userId, product.productId, quantity);
        _replaceItems(serverItems, notify: false);
      },
      rollbackItems: rollbackItems,
    );
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  Future<void> clearSynced(int? userId) async {
    final rollbackItems = _copyItems();
    clear();
    if (userId == null) {
      return;
    }

    await _sync(
      () async {
        final serverItems = await api.clearCart(userId);
        _replaceItems(serverItems, notify: false);
      },
      rollbackItems: rollbackItems,
    );
  }

  Future<void> loadForUser(int userId, {bool mergeLocal = true}) async {
    this.userId = userId;
    final localItems = _copyItems();
    await _sync(
      () async {
        if (mergeLocal) {
          for (final item in localItems) {
            await api.addCartItem(
              userId,
              item.product.productId,
              item.quantity,
            );
          }
        }
        final serverItems = await api.getCart(userId);
        _replaceItems(serverItems, notify: false);
      },
      rollbackItems: localItems,
    );
  }

  void clearSession() {
    userId = null;
    isSyncing = false;
    error = null;
    items.clear();
    notifyListeners();
  }

  Future<bool> _sync(
    Future<void> Function() action, {
    required List<CartItem> rollbackItems,
  }) async {
    isSyncing = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _replaceItems(rollbackItems, notify: false);
      error = e.toString();
      return false;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  int _quantityFor(int productId) {
    final index =
        items.indexWhere((item) => item.product.productId == productId);
    return index < 0 ? 0 : items[index].quantity;
  }

  List<CartItem> _copyItems() => items
      .map((item) => CartItem(product: item.product, quantity: item.quantity))
      .toList();

  void _replaceItems(List<CartItem> nextItems, {bool notify = true}) {
    items
      ..clear()
      ..addAll(nextItems.map(
        (item) => CartItem(product: item.product, quantity: item.quantity),
      ));
    if (notify) {
      notifyListeners();
    }
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

  void clearSession() {
    resetLoadState();
    availableTables = [];
    reservations = [];
    notifyListeners();
  }
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

  void clearSession() {
    resetLoadState();
    notifications = [];
    notifyListeners();
  }
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

  void clearSession() {
    resetLoadState();
    conversation = null;
    messages = [];
    notifyListeners();
  }
}

class SessionCoordinator {
  Future<void> logout({
    required AuthProvider auth,
    required CartProvider cart,
    required ReservationProvider reservations,
    required NotificationProvider notifications,
    required ChatProvider chat,
  }) async {
    await auth.logout();
    cart.clearSession();
    reservations.clearSession();
    notifications.clearSession();
    chat.clearSession();
  }
}

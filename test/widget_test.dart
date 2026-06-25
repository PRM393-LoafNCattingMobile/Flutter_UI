import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/login_screen.dart';
import 'package:loafncatting_mobile/screens/register_screen.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('buildLoafTheme uses the approved orange-white cafe palette', () {
    final theme = buildLoafTheme();

    expect(theme.colorScheme.primary, loafOrange);
    expect(theme.colorScheme.secondary, loafSoftOrange);
    expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
    expect(theme.scaffoldBackgroundColor, loafCream);
  });

  test('CartProvider clamps added quantity to available stock', () {
    final cart = CartProvider();
    final product = Product(
      productId: 1,
      name: 'Cappuccino',
      price: 45000,
      unitInStock: 2,
      categoryId: 1,
      categoryName: 'Drinks',
      isAvailable: true,
    );

    final firstAdd = cart.add(product, 1);
    final secondAdd = cart.add(product, 5);

    expect(firstAdd, 1);
    expect(secondAdd, 1);
    expect(cart.items.single.quantity, 2);
    expect(cart.count, 2);
  });

  test('Product.fromJson keeps raw availability and distinct orderability', () {
    final product = Product.fromJson({
      'productId': 1,
      'name': 'Cappuccino',
      'price': 45000,
      'unitInStock': 0,
      'categoryId': 1,
      'categoryName': 'Drinks',
      'isAvailable': true,
      'canOrder': false,
    });

    expect(product.isAvailable, isTrue);
    expect(product.canOrder, isFalse);
  });

  test('CartProvider loadForUser merges local items into persisted cart',
      () async {
    final product = Product(
      productId: 1,
      name: 'Cappuccino',
      price: 45000,
      unitInStock: 5,
      categoryId: 1,
      categoryName: 'Drinks',
      isAvailable: true,
    );
    final api = _FakeCartApiService(
      serverItems: [CartItem(product: product, quantity: 3)],
    );
    final cart = CartProvider(api)..add(product, 2);

    await cart.loadForUser(7);

    expect(api.addCartItemCalls, [
      _CartApiCall(userId: 7, productId: product.productId, quantity: 2),
    ]);
    expect(api.getCartUserIds, [7]);
    expect(cart.count, 3);
    expect(cart.items.single.product.name, 'Cappuccino');
  });

  test('CartProvider addWithSyncResult reports auth failure distinctly',
      () async {
    final product = Product(
      productId: 1,
      name: 'Cappuccino',
      price: 45000,
      unitInStock: 5,
      categoryId: 1,
      categoryName: 'Drinks',
      isAvailable: true,
    );
    final cart = CartProvider(_FailingCartApiService(
      ApiException('Unauthorized', statusCode: 401),
    ));

    final result = await cart.addWithSyncResult(product, 1, 7);

    expect(result.status, CartAddStatus.authRequired);
    expect(result.addedQuantity, 0);
    expect(cart.items, isEmpty);
  });

  test('CartProvider addWithSyncResult reports stock limit distinctly',
      () async {
    final product = Product(
      productId: 1,
      name: 'Cappuccino',
      price: 45000,
      unitInStock: 1,
      categoryId: 1,
      categoryName: 'Drinks',
      isAvailable: true,
    );
    final cart = CartProvider(_FakeCartApiService(serverItems: const []))
      ..add(product, 1);

    final result = await cart.addWithSyncResult(product, 1, 7);

    expect(result.status, CartAddStatus.stockLimit);
    expect(result.addedQuantity, 0);
    expect(cart.count, 1);
  });

  testWidgets('Login screen validates empty credentials before submit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(ApiService()),
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.signInButton));
    await tester.pump();

    expect(find.text('Vui lòng nhập email hoặc số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
  });

  testWidgets('Register screen validates empty fields before submit',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(ApiService()),
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const RegisterScreen(),
        ),
      ),
    );

    await tester.tap(find.text(AppStrings.registerButton));
    await tester.pump();

    expect(find.text('Vui lòng nhập tên của bạn'), findsOneWidget);
    expect(find.text('Vui lòng nhập email'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
  });

  test('SessionCoordinator logout clears persisted and in-memory session data',
      () async {
    final authUser = AuthUser(
      userId: 7,
      name: 'Test User',
      email: 'test@example.com',
      phoneNumber: '0123456789',
      roleName: 'Customer',
      token: 'token-123',
    );

    SharedPreferences.setMockInitialValues({
      'authUser': jsonEncode(authUser.toJson()),
    });

    final auth = AuthProvider(ApiService())..user = authUser;
    final cart = CartProvider()
      ..add(
        Product(
          productId: 1,
          name: 'Latte',
          price: 55000,
          unitInStock: 3,
          categoryId: 1,
          categoryName: 'Drinks',
          isAvailable: true,
        ),
        2,
      );
    final reservations = ReservationProvider(ApiService())
      ..availableTables = [
        CafeTable(
          tableId: 1,
          tableName: 'A1',
          capacity: 4,
          statusName: 'Available',
        ),
      ]
      ..reservations = [
        Reservation(
          reservationId: 1,
          userId: authUser.userId,
          date: '2026-06-09',
          time: '18:00',
          guestName: 'Test User',
          guestPhoneNumber: authUser.phoneNumber,
          numberOfGuests: 2,
          statusName: 'Pending',
          tableId: 1,
          tableName: 'A1',
        ),
      ];
    final notifications = NotificationProvider(ApiService())
      ..notifications = [
        AppNotification(
          notificationId: 1,
          userId: authUser.userId,
          title: 'Hi',
          content: 'Welcome back',
          isRead: false,
          createdAt: DateTime(2026, 6, 9),
        ),
      ];
    final chat = ChatProvider(ApiService())
      ..conversation = Conversation(conversationId: 2, userId: authUser.userId)
      ..messages = [
        ChatMessage(
          messageId: 1,
          conversationId: 2,
          senderUserId: authUser.userId,
          sender: authUser.name,
          content: 'Hello',
          isRead: true,
          sentAt: DateTime(2026, 6, 9, 10),
        ),
      ];

    await SessionCoordinator().logout(
      auth: auth,
      cart: cart,
      reservations: reservations,
      notifications: notifications,
      chat: chat,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(auth.user, isNull);
    expect(prefs.getString('authUser'), isNull);
    expect(cart.items, isEmpty);
    expect(reservations.availableTables, isEmpty);
    expect(reservations.reservations, isEmpty);
    expect(notifications.notifications, isEmpty);
    expect(chat.conversation, isNull);
    expect(chat.messages, isEmpty);
  });
}

class _FakeCartApiService extends ApiService {
  _FakeCartApiService({required this.serverItems});

  final List<CartItem> serverItems;
  final List<_CartApiCall> addCartItemCalls = [];
  final List<int> getCartUserIds = [];

  @override
  Future<List<CartItem>> getCart(int userId) async {
    getCartUserIds.add(userId);
    return serverItems;
  }

  @override
  Future<List<CartItem>> addCartItem(
      int userId, int productId, int quantity) async {
    addCartItemCalls.add(
      _CartApiCall(userId: userId, productId: productId, quantity: quantity),
    );
    return serverItems;
  }
}

class _FailingCartApiService extends ApiService {
  _FailingCartApiService(this.exception);

  final ApiException exception;

  @override
  Future<List<CartItem>> addCartItem(
      int userId, int productId, int quantity) async {
    throw exception;
  }
}

class _CartApiCall {
  const _CartApiCall({
    required this.userId,
    required this.productId,
    required this.quantity,
  });

  final int userId;
  final int productId;
  final int quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CartApiCall &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          productId == other.productId &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(userId, productId, quantity);
}

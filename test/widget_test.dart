import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/login_screen.dart';
import 'package:loafncatting_mobile/screens/register_screen.dart';
import 'package:loafncatting_mobile/screens/menu_screen.dart';
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

  test('Product detail no longer owns item-note UI', () {
    final detailContent =
        File('lib/screens/product_detail_screen.dart').readAsStringSync();
    final stringsContent =
        File('lib/core/constants/app_strings.dart').readAsStringSync();

    expect(detailContent, isNot(contains('productNoteLabel')));
    expect(detailContent, isNot(contains('productNoteHint')));
    expect(stringsContent, isNot(contains('productNoteLabel')));
    expect(stringsContent, isNot(contains('productNoteHint')));
  });

  test('CatalogProvider applies local menu filters and sort order', () {
    final catalog = CatalogProvider(
      ApiService(),
      initialProducts: [
        Product(
          productId: 1,
          name: 'Latte',
          price: 55000,
          unitInStock: 4,
          categoryId: 1,
          categoryName: 'Drinks',
          isAvailable: true,
        ),
        Product(
          productId: 2,
          name: 'Discount Cake',
          price: 95000,
          discountPrice: 75000,
          unitInStock: 2,
          categoryId: 2,
          categoryName: 'Dessert',
          isAvailable: true,
        ),
        Product(
          productId: 3,
          name: 'Sold Out Tea',
          price: 45000,
          unitInStock: 0,
          categoryId: 1,
          categoryName: 'Drinks',
          isAvailable: false,
        ),
      ],
    );

    catalog.applyMenuFilters(
      availability: ProductAvailabilityFilter.availableOnly,
      minPrice: 50000,
      maxPrice: 100000,
      discountedOnly: true,
      sortOption: ProductSortOption.priceLowHigh,
    );

    expect(catalog.products.map((product) => product.name), ['Discount Cake']);
    expect(catalog.activeFilterLabels,
        ['Còn hàng', '50k - 100k', 'Giá Thấp - Cao', 'Giảm giá']);
  });

  test('CatalogProvider resets local menu filters', () {
    final catalog = CatalogProvider(
      ApiService(),
      initialProducts: [
        Product(
          productId: 1,
          name: 'Latte',
          price: 55000,
          unitInStock: 4,
          categoryId: 1,
          categoryName: 'Drinks',
          isAvailable: true,
        ),
      ],
    )..applyMenuFilters(
        availability: ProductAvailabilityFilter.availableOnly,
        minPrice: 50000,
        maxPrice: 100000,
        discountedOnly: true,
        sortOption: ProductSortOption.priceHighLow,
      );

    catalog.resetMenuFilters();

    expect(catalog.hasMenuFilters, isFalse);
    expect(catalog.activeFilterLabels, isEmpty);
    expect(catalog.products.single.name, 'Latte');
  });

  testWidgets('Menu search keeps Vietnamese IME text and submits as search',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final searchFieldFinder = find.byType(TextField).first;
    final searchField = tester.widget<TextField>(searchFieldFinder);
    expect(searchField.textInputAction, TextInputAction.search);
    expect(searchField.autocorrect, isFalse);
    expect(searchField.enableSuggestions, isFalse);
    expect(searchField.smartDashesType, SmartDashesType.disabled);
    expect(searchField.smartQuotesType, SmartQuotesType.disabled);
    expect(searchField.hintLocales, const [Locale('vi', 'VN')]);

    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, 'cà phê sữa');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await tester.pump();

    expect(find.text('cà phê sữa'), findsOneWidget);
    expect(api.productSearches.last, 'cà phê sữa');
  });

  testWidgets('Menu search repairs UniKey Telex tone replacement on Windows',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final searchFieldFinder = find.byType(TextField).first;
    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, 'xin chao');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'xin cho',
        selection: TextSelection.collapsed(offset: 7),
      ),
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyF);
    await tester.pump();

    expect(find.text('xin ch\u00e0o'), findsOneWidget);
  });

  testWidgets('Menu search allows Android soft-keyboard deletion at word end',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final searchFieldFinder = find.byType(TextField).first;
    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, 'xin chao');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'xin cho',
        selection: TextSelection.collapsed(offset: 7),
      ),
    );
    await tester.pump();

    expect(find.text('xin cho'), findsOneWidget);
    expect(find.text('xin chao'), findsNothing);
    expect(find.text('xin ch\u00e0o'), findsNothing);
  });

  testWidgets('Menu search applies UniKey Telex dot tone from captured key',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final searchFieldFinder = find.byType(TextField).first;
    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, 'ban');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyJ);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'bn',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyJ);
    await tester.pump();

    expect(find.text('b\u1ea1n'), findsOneWidget);
  });

  testWidgets('Menu search allows vowel deletion without guessing a tone',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final searchFieldFinder = find.byType(TextField).first;
    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, 'ban');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'bn',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    await tester.pump();

    expect(find.text('bn'), findsOneWidget);
    expect(find.text('ban'), findsNothing);
    expect(find.text('b\u00e0n'), findsNothing);
  });

  testWidgets('Menu search still allows manual vowel deletion',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final searchFieldFinder = find.byType(TextField).first;
    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, 'xin chao');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'xin chao',
        selection: TextSelection.collapsed(offset: 6),
      ),
    );
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'xin cho',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );
    await tester.pump();

    expect(find.text('xin cho'), findsOneWidget);
    expect(find.text('xin ch\u00e0o'), findsNothing);
  });

  testWidgets('Menu filter sheet renders Vietnamese labels',
      (WidgetTester tester) async {
    final api = _RecordingMenuApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          theme: buildLoafTheme(),
          home: const MenuScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Bộ lọc'), findsOneWidget);
    expect(find.text('Tình trạng'), findsOneWidget);
    expect(find.text('Tất cả'), findsAtLeastNWidgets(2));
    expect(find.text('Còn hàng'), findsAtLeastNWidgets(2));
    expect(find.text('Giá'), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(find.text('Sắp xếp'), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Tên A-Z'), findsOneWidget);
    expect(find.text('Giá Thấp - Cao'), findsOneWidget);
    expect(find.text('Giá Cao - Thấp'), findsOneWidget);
    expect(find.text('Chỉ món giảm giá'), findsOneWidget);
    expect(find.text('Áp dụng'), findsOneWidget);
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

class _RecordingMenuApiService extends ApiService {
  final List<String?> productSearches = [];

  @override
  Future<List<Category>> getCategories() async => [
        Category(categoryId: 1, name: 'Đồ uống'),
      ];

  @override
  Future<List<Product>> getProducts({int? categoryId, String? search}) async {
    productSearches.add(search);
    return [
      Product(
        productId: 1,
        name: 'Cà phê sữa',
        price: 45000,
        unitInStock: 5,
        categoryId: 1,
        categoryName: 'Đồ uống',
        isAvailable: true,
      ),
    ];
  }
}

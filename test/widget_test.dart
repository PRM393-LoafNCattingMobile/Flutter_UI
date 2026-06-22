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
      priceRange: ProductPriceRange.from50kTo100k,
      discountedOnly: true,
      sortOption: ProductSortOption.priceLowHigh,
    );

    expect(catalog.products.map((product) => product.name), ['Discount Cake']);
    expect(catalog.activeFilterLabels,
        ['Còn hàng', '50k-100k', 'Giá thấp-cao', 'Giảm giá']);
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
        priceRange: ProductPriceRange.from50kTo100k,
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

  testWidgets('Menu search preserves base text when UniKey hides the tone key',
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

    expect(find.text('xin chao'), findsOneWidget);
    expect(find.text('xin cho'), findsNothing);
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

  testWidgets('Menu search does not guess grave tone without a captured key',
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

    expect(find.text('ban'), findsOneWidget);
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
    expect(find.text('Sắp xếp'), findsOneWidget);
    expect(find.text('Mặc định'), findsOneWidget);
    expect(find.text('Tên A-Z'), findsOneWidget);
    expect(find.text('Giá thấp-cao'), findsOneWidget);
    expect(find.text('Giá cao-thấp'), findsOneWidget);
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

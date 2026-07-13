import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/main.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/cart_screen.dart';
import 'package:loafncatting_mobile/screens/chat_screen.dart';
import 'package:loafncatting_mobile/screens/checkout_screen.dart';
import 'package:loafncatting_mobile/screens/home_screen.dart';
import 'package:loafncatting_mobile/screens/more_screen.dart';
import 'package:loafncatting_mobile/screens/notifications_screen.dart';
import 'package:loafncatting_mobile/screens/menu_screen.dart';
import 'package:loafncatting_mobile/screens/product_detail_screen.dart';
import 'package:loafncatting_mobile/screens/reservation_history_screen.dart';
import 'package:loafncatting_mobile/screens/reservation_screen.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppStrings and AppRoutes expose the expected centralized values', () {
    expect(AppStrings.appTitle, "Loaf'NCatting");
    expect(AppStrings.signInButton, 'Đăng nhập');
    expect(AppStrings.registerButton, 'Đăng ký');
    expect(AppStrings.homeNavLabel, 'Trang chủ');
    expect(AppStrings.menuSearchHint, 'Tìm món');
    expect(AppStrings.cartTitle(2), 'Giỏ hàng (2)');
    expect(AppStrings.menuItemsToday(3), '3 món hôm nay');
    expect(
      AppStrings.orderPlacedSuccessMessage('Lan'),
      'Đơn của Lan đã được gửi đến quán.',
    );
    expect(
      AppStrings.productAddedToCart('Latte'),
      'Latte đã được thêm vào giỏ hàng',
    );
    expect(AppStrings.stockCountLabel(4), 'Còn 4');
    expect(AppStrings.addedItemsToCartMessage(1), 'Đã thêm 1 món vào giỏ hàng');
    expect(AppStrings.addedItemsToCartMessage(2), 'Đã thêm 2 món vào giỏ hàng');
    expect(AppStrings.takeAwayOrderType, 'Mang đi');
    expect(AppStrings.bankTransferPaymentMethod, 'Chuyển khoản ngân hàng');
    expect(AppStrings.perfectWithTitle, 'Hợp với');
    expect(AppStrings.similarItemsTitle, 'Món tương tự');

    expect(AppRoutes.splash, '/');
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.register, '/register');
    expect(AppRoutes.home, '/home');
  });

  test('money formats prices with dot thousands and VND suffix', () {
    expect(money(25000), '25.000 VND');
    expect(money(1250000), '1.250.000 VND');
  });

  testWidgets(
      'LoafApp wires centralized title and named routes into MaterialApp',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(LoafApp(api: ApiService()));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final routes = materialApp.routes;

    expect(materialApp.title, AppStrings.appTitle);
    expect(routes, isNotNull);
    expect(
        routes!.keys,
        containsAll(<String>[
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.home,
        ]));
  });

  testWidgets('HomeScreen exposes bottom navigation labels from AppStrings',
      (tester) async {
    final api = _FakeApiService();

    await tester.pumpWidget(
      _buildTestApp(
        child: const HomeScreen(),
        api: api,
        auth: AuthProvider(api),
        cart: CartProvider(),
        catalog: CatalogProvider(api),
        reservations: ReservationProvider(api),
      ),
    );
    await tester.pump();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    final labels = navigationBar.destinations
        .whereType<NavigationDestination>()
        .map((destination) => destination.label)
        .toList();

    expect(labels, <String>[
      AppStrings.homeNavLabel,
      AppStrings.menuNavLabel,
      AppStrings.reservationsNavLabel,
      AppStrings.catsNavLabel,
      AppStrings.profileNavLabel,
    ]);
  });

  testWidgets('MoreScreen renders centralized labels from AppStrings',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoreScreen()));

    expect(find.text(AppStrings.homeNavLabel), findsOneWidget);
    expect(find.text(AppStrings.moreHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.notificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.storeLocationTitle), findsOneWidget);
    expect(find.text(AppStrings.chatTitle), findsOneWidget);
  });

  testWidgets('CartScreen renders centralized empty state copy',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const CartScreen(),
        cart: CartProvider(),
      ),
    );

    expect(find.text(AppStrings.cartTitle(0)), findsOneWidget);
    expect(find.text(AppStrings.cartEmptyMessage), findsOneWidget);
  });

  testWidgets('CartScreen renders centralized populated cart copy',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cart = CartProvider()..add(_sampleProduct(name: 'Latte'), 2);

    await tester.pumpWidget(
      _buildTestApp(
        child: const CartScreen(),
        cart: cart,
      ),
    );

    expect(find.text(AppStrings.cartTitle(2)), findsOneWidget);
    expect(find.text(AppStrings.cartHeroTitle), findsOneWidget);
    expect(find.text('Latte'), findsAtLeastNWidgets(1));
    expect(find.text(AppStrings.totalLabel), findsOneWidget);
    expect(find.text(AppStrings.checkoutButton), findsOneWidget);
  });

  testWidgets('CheckoutScreen shows empty-cart guard copy', (tester) async {
    final api = _FakeApiService();
    final auth = AuthProvider(api)..user = _sampleUser();

    await tester.pumpWidget(
      _buildTestApp(
        child: const CheckoutScreen(),
        api: api,
        auth: auth,
        cart: CartProvider(),
      ),
    );

    expect(find.text(AppStrings.checkoutTitle), findsOneWidget);
    expect(find.text(AppStrings.checkoutEmptyCartMessage), findsOneWidget);
    expect(find.text(AppStrings.backToCartButton), findsOneWidget);
  });

  testWidgets('CheckoutScreen shows login-required guard copy', (tester) async {
    final cart = CartProvider()..add(_sampleProduct(), 1);

    await tester.pumpWidget(
      _buildTestApp(
        child: const CheckoutScreen(),
        cart: cart,
      ),
    );

    expect(find.text(AppStrings.checkoutLoginRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.goToLoginButton), findsOneWidget);
  });

  testWidgets('CheckoutScreen routes bank-transfer orders through PayOS',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeApiService(createPaymentLinkError: 'ĐÃ_GỌI_PAYOS');
    final auth = AuthProvider(api)..user = _sampleUser();
    final cart = CartProvider()..add(_sampleProduct(), 1);

    await tester.pumpWidget(
      _buildTestApp(
        child: const CheckoutScreen(),
        api: api,
        auth: auth,
        cart: cart,
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.bankTransferPaymentMethod).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.placeOrderButton));
    await tester.tap(find.text(AppStrings.placeOrderButton));
    await tester.pump();

    expect(api.createOrderCallCount, 1);
    expect(api.createPaymentLinkCallCount, 1);
    expect(api.lastCreateOrderBody?['paymentMethod'],
        AppStrings.bankTransferPaymentMethod);
    expect(api.lastCreateOrderBody?['orderType'], AppStrings.takeAwayOrderType);
    expect(
      find.text('Chưa thể xử lý thanh toán. Vui lòng thử lại sau.'),
      findsOneWidget,
    );
  });

  testWidgets('ReservationScreen guards the unauthenticated flow safely',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const ReservationScreen(),
        reservations: ReservationProvider(_FakeApiService()),
      ),
    );

    expect(find.text(AppStrings.checkoutLoginRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.goToLoginButton), findsOneWidget);
    expect(find.text(AppStrings.confirmReservationButton), findsNothing);

    await tester.tap(find.text(AppStrings.goToLoginButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('NotificationsScreen guards unauthenticated users safely',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const NotificationsScreen(),
        notifications: NotificationProvider(_FakeApiService()),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.checkoutLoginRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.goToLoginButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ChatScreen guards unauthenticated users safely', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const ChatScreen(),
        chat: ChatProvider(_FakeApiService()),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.checkoutLoginRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.goToLoginButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ReservationHistoryScreen guards unauthenticated users safely',
      (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: const ReservationHistoryScreen(),
        reservations: ReservationProvider(_FakeApiService()),
      ),
    );
    await tester.pump();

    expect(find.text(AppStrings.checkoutLoginRequiredMessage), findsOneWidget);
    expect(find.text(AppStrings.goToLoginButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MenuScreen renders extracted content and still adds to cart',
      (tester) async {
    final api = _FakeApiService(
      categories: [
        Category(categoryId: 1, name: 'Drinks'),
      ],
      products: [
        _sampleProduct(),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        child: const MenuScreen(),
        api: api,
        catalog: CatalogProvider(api),
        cart: CartProvider(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.menuSearchHint), findsOneWidget);
    expect(find.text(AppStrings.popularPicksTitle), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    expect(find.text('Latte'), findsAtLeastNWidgets(1));
    expect(find.text(AppStrings.addButton), findsOneWidget);

    await tester.tap(find.text(AppStrings.addButton));
    await tester.pump();

    expect(find.text(AppStrings.productAddedToCart('Latte')), findsOneWidget);
  });

  testWidgets('MenuScreen treats zero-stock products as out of stock',
      (tester) async {
    final api = _FakeApiService(
      categories: [
        Category(categoryId: 1, name: 'Drinks'),
      ],
      products: [
        _sampleProduct(unitInStock: 0),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        child: const MenuScreen(),
        api: api,
        catalog: CatalogProvider(api),
        cart: CartProvider(api),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.outOfStockLabel), findsOneWidget);
    expect(find.text(AppStrings.inStockLabel), findsNothing);

    final addButton = find.widgetWithText(FilledButton, AppStrings.addButton);
    expect(tester.widget<FilledButton>(addButton).onPressed, isNull);
  });

  testWidgets('ReservationScreen submits without requiring table selection',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeApiService(
      availableTables: [
        CafeTable(
          tableId: 8,
          tableName: 'Window 2',
          capacity: 4,
          statusName: 'Available',
        ),
      ],
    );
    final auth = AuthProvider(api)..user = _sampleUser();
    final reservations = ReservationProvider(api);

    await tester.pumpWidget(
      _buildTestApp(
        child: const ReservationScreen(),
        api: api,
        auth: auth,
        reservations: reservations,
      ),
    );

    expect(find.text(AppStrings.reservationHeroTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.confirmReservationButton));
    await tester.pump();

    expect(find.text(AppStrings.reservationCreatedMessage), findsOneWidget);
    expect(api.lastCreateReservationBody?['tableId'], isNull);
  });

  testWidgets(
      'ReservationScreen seeds guest details once without reseeding on rebuild',
      (tester) async {
    final api = _FakeApiService();
    final auth = AuthProvider(api)..user = _sampleUser();

    await tester.pumpWidget(
      _buildTestApp(
        child: const ReservationScreen(),
        api: api,
        auth: auth,
        reservations: ReservationProvider(api),
      ),
    );
    await tester.pump();

    final nameField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == AppStrings.guestNameLabel,
    );
    final phoneField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == AppStrings.phoneNumberLabel,
    );

    expect(
      tester.widget<TextField>(nameField).controller?.text,
      _sampleUser().name,
    );
    expect(
      tester.widget<TextField>(phoneField).controller?.text,
      _sampleUser().phoneNumber,
    );

    await tester.enterText(nameField, '');
    await tester.enterText(phoneField, '');
    auth.notifyListeners();
    await tester.pump();

    expect(tester.widget<TextField>(nameField).controller?.text, '');
    expect(tester.widget<TextField>(phoneField).controller?.text, '');
  });

  testWidgets(
      'ProductDetailScreen renders centralized copy and adds an item to cart',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cart = CartProvider();
    final product = _sampleProduct(description: null, unitInStock: 2);

    await tester.pumpWidget(
      _buildTestApp(
        child: ProductDetailScreen(product: product),
        cart: cart,
      ),
    );

    expect(find.text(AppStrings.productNoDescription), findsOneWidget);
    expect(find.text(AppStrings.addToCartButton), findsOneWidget);

    await tester.tap(find.text(AppStrings.addToCartButton));
    await tester.pump();

    expect(find.text(AppStrings.addedItemsToCartMessage(1)), findsOneWidget);
    expect(cart.count, 1);
  });

  test('listed files no longer use raw named-route literals where prohibited',
      () {
    final mainFile = File('lib/main.dart');
    final splashFile = File('lib/screens/splash_screen.dart');
    final loginFile = File('lib/screens/login_screen.dart');
    final registerFile = File('lib/screens/register_screen.dart');
    final profileFile = File('lib/screens/profile_screen.dart');

    final mainContent = mainFile.readAsStringSync();
    final splashContent = splashFile.readAsStringSync();
    final loginContent = loginFile.readAsStringSync();
    final registerContent = registerFile.readAsStringSync();
    final profileContent = profileFile.readAsStringSync();

    expect(mainContent, contains('AppRoutes.login'));
    expect(mainContent, isNot(contains("'/login'")));

    expect(splashContent, isNot(contains("'/home'")));
    expect(loginContent, isNot(contains("'/register'")));
    expect(registerContent, isNot(contains("'/home'")));
    expect(profileContent, isNot(contains("'/login'")));
  });
}

Widget _buildTestApp({
  required Widget child,
  ApiService? api,
  AuthProvider? auth,
  CartProvider? cart,
  CatalogProvider? catalog,
  ReservationProvider? reservations,
  NotificationProvider? notifications,
  ChatProvider? chat,
}) {
  final resolvedApi = api ?? _FakeApiService();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth ?? AuthProvider(resolvedApi),
      ),
      ChangeNotifierProvider<CartProvider>.value(
        value: cart ?? CartProvider(resolvedApi),
      ),
      ChangeNotifierProvider<CatalogProvider>.value(
        value: catalog ?? CatalogProvider(resolvedApi),
      ),
      ChangeNotifierProvider<ReservationProvider>.value(
        value: reservations ?? ReservationProvider(resolvedApi),
      ),
      ChangeNotifierProvider<NotificationProvider>.value(
        value: notifications ?? NotificationProvider(resolvedApi),
      ),
      ChangeNotifierProvider<ChatProvider>.value(
        value: chat ?? ChatProvider(resolvedApi),
      ),
    ],
    child: MaterialApp(
      routes: {
        AppRoutes.login: (_) => const SizedBox.shrink(),
      },
      home: child,
    ),
  );
}

AuthUser _sampleUser() => AuthUser(
      userId: 7,
      name: 'Lan',
      email: 'lan@example.com',
      phoneNumber: '0123456789',
      roleName: 'Customer',
      token: 'token-123',
    );

Product _sampleProduct({
  String name = 'Latte',
  String? description = 'Creamy milk coffee',
  int unitInStock = 3,
}) =>
    Product(
      productId: 1,
      name: name,
      description: description,
      picture: 'https://example.com/product.png',
      price: 55000,
      unitInStock: unitInStock,
      categoryId: 1,
      categoryName: 'Drinks',
      isAvailable: true,
    );

class _FakeApiService extends ApiService {
  _FakeApiService({
    this.categories = const <Category>[],
    this.products = const <Product>[],
    this.availableTables = const <CafeTable>[],
    this.createPaymentLinkError,
  });

  final List<Category> categories;
  final List<Product> products;
  final List<CafeTable> availableTables;
  final String? createPaymentLinkError;
  int createOrderCallCount = 0;
  int createPaymentLinkCallCount = 0;
  Map<String, dynamic>? lastCreateOrderBody;
  Map<String, dynamic>? lastCreateReservationBody;

  @override
  Future<List<Category>> getCategories() async => categories;

  @override
  Future<List<Product>> getProducts({int? categoryId, String? search}) async =>
      products;

  @override
  Future<List<CafeTable>> getAvailableTables({
    required String date,
    required String time,
    required int guestCount,
  }) async =>
      availableTables;

  @override
  Future<Reservation> createReservation(Map<String, dynamic> body) async {
    lastCreateReservationBody = body;
    return Reservation(
        reservationId: 11,
        userId: body['userId'] as int?,
        date: body['date'] as String,
        time: body['time'] as String,
        guestName: body['guestName'] as String,
        guestPhoneNumber: body['guestPhoneNumber'] as String,
        numberOfGuests: body['numberOfGuests'] as int,
        note: body['note'] as String?,
        statusName: 'Pending',
        tableId: body['tableId'] as int? ?? 8,
        tableName: 'Window 2',
      );
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> body) async {
    createOrderCallCount += 1;
    lastCreateOrderBody = body;
    return {
      'orderId': 99,
      'orderDate': '2026-06-30T10:00:00',
      'totalPrice': 55000,
      'customerUserId': body['userId'],
      'statusName': 'Đang chờ',
      'paymentStatus': 'Đang chờ thanh toán',
      'items': const [],
      'customerName': 'Lan',
    };
  }

  @override
  Future<Order?> getPendingPaymentOrder(int userId) async => null;

  @override
  Future<Map<String, dynamic>> createPaymentLink(int orderId) async {
    createPaymentLinkCallCount += 1;
    if (createPaymentLinkError != null) {
      throw ApiException(createPaymentLinkError!);
    }
    return {'checkoutUrl': 'https://example.com/payos/$orderId'};
  }
}

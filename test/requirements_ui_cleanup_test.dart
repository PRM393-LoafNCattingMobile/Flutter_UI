import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/main.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/cart_screen.dart';
import 'package:loafncatting_mobile/screens/checkout_screen.dart';
import 'package:loafncatting_mobile/screens/home_screen.dart';
import 'package:loafncatting_mobile/screens/more_screen.dart';
import 'package:loafncatting_mobile/screens/menu_screen.dart';
import 'package:loafncatting_mobile/screens/product_detail_screen.dart';
import 'package:loafncatting_mobile/screens/reservation_screen.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppStrings and AppRoutes expose the expected centralized values', () {
    expect(AppStrings.appTitle, "Loaf'NCatting");
    expect(AppStrings.signInButton, 'Sign in');
    expect(AppStrings.registerButton, 'Register');
    expect(AppStrings.homeNavLabel, 'Home');
    expect(AppStrings.menuSearchHint, 'Search menu');
    expect(AppStrings.cartTitle(2), 'Cart (2)');
    expect(AppStrings.menuItemsToday(3), '3 items today');
    expect(
      AppStrings.orderPlacedSuccessMessage('Lan'),
      "Lan's order has been sent to the cafe.",
    );
    expect(AppStrings.productAddedToCart('Latte'), 'Latte added to cart');
    expect(AppStrings.stockCountLabel(4), '4 left');
    expect(AppStrings.addedItemsToCartMessage(1), '1 item added to cart');
    expect(AppStrings.addedItemsToCartMessage(2), '2 items added to cart');

    expect(AppRoutes.splash, '/');
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.register, '/register');
    expect(AppRoutes.home, '/home');
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

    expect(find.text(AppStrings.moreTitle), findsOneWidget);
    expect(find.text(AppStrings.moreHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.notificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.storeLocationTitle), findsOneWidget);
    expect(find.text(AppStrings.chatTitle), findsOneWidget);
    expect(find.text(AppStrings.profileTitle), findsOneWidget);
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
    expect(find.text('Latte'), findsAtLeastNWidgets(1));
    expect(find.text(AppStrings.addButton), findsOneWidget);

    await tester.tap(find.text(AppStrings.addButton));
    await tester.pump();

    expect(find.text(AppStrings.productAddedToCart('Latte')), findsOneWidget);
  });

  testWidgets('ReservationScreen keeps reservation flow interactive',
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
    expect(find.text(AppStrings.loadAvailableTablesButton), findsOneWidget);

    await tester.tap(find.text(AppStrings.loadAvailableTablesButton));
    await tester.pump();
    await tester.pump();

    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Window 2').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.confirmReservationButton));
    await tester.pump();

    expect(find.text(AppStrings.reservationCreatedMessage), findsOneWidget);
  });

  testWidgets('ReservationScreen drops stale table selection after reload',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final api = _FakeApiService(
      availableTablesByRequest: {
        '2026-06-19|18:00|2': [
          CafeTable(
            tableId: 8,
            tableName: 'Window 2',
            capacity: 4,
            statusName: 'Available',
          ),
        ],
        '2026-06-20|18:00|2': [
          CafeTable(
            tableId: 9,
            tableName: 'Patio 1',
            capacity: 4,
            statusName: 'Available',
          ),
        ],
      },
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
    await tester.pump();

    final dateField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == AppStrings.dateLabel,
    );
    final loadButton = find.text(AppStrings.loadAvailableTablesButton);
    final tableDropdown = find.byType(DropdownButtonFormField<int>);
    final confirmButton = find.widgetWithText(
      FilledButton,
      AppStrings.confirmReservationButton,
    );

    await tester.enterText(dateField, '2026-06-19');
    await tester.tap(loadButton);
    await tester.pump();
    await tester.pump();

    await tester.tap(tableDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Window 2').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(confirmButton).onPressed,
      isNotNull,
    );

    await tester.enterText(dateField, '2026-06-20');
    await tester.tap(loadButton);
    await tester.pump();
    await tester.pump();

    expect(
      tester.widget<DropdownButtonFormField<int>>(tableDropdown).initialValue,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(confirmButton).onPressed,
      isNull,
    );

    await tester.tap(tableDropdown);
    await tester.pumpAndSettle();

    expect(find.textContaining('Patio 1').last, findsOneWidget);
    expect(find.textContaining('Window 2'), findsNothing);
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
}) {
  final resolvedApi = api ?? _FakeApiService();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth ?? AuthProvider(resolvedApi),
      ),
      ChangeNotifierProvider<CartProvider>.value(
        value: cart ?? CartProvider(),
      ),
      ChangeNotifierProvider<CatalogProvider>.value(
        value: catalog ?? CatalogProvider(resolvedApi),
      ),
      ChangeNotifierProvider<ReservationProvider>.value(
        value: reservations ?? ReservationProvider(resolvedApi),
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
    this.availableTablesByRequest = const <String, List<CafeTable>>{},
  });

  final List<Category> categories;
  final List<Product> products;
  final List<CafeTable> availableTables;
  final Map<String, List<CafeTable>> availableTablesByRequest;

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
      availableTablesByRequest['$date|$time|$guestCount'] ?? availableTables;

  @override
  Future<Reservation> createReservation(Map<String, dynamic> body) async =>
      Reservation(
        reservationId: 11,
        userId: body['userId'] as int?,
        date: body['date'] as String,
        time: body['time'] as String,
        guestName: body['guestName'] as String,
        guestPhoneNumber: body['guestPhoneNumber'] as String,
        numberOfGuests: body['numberOfGuests'] as int,
        note: body['note'] as String?,
        statusName: 'Pending',
        tableId: body['tableId'] as int,
        tableName: 'Window 2',
      );
}

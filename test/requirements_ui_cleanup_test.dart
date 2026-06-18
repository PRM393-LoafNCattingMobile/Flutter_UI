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
import 'package:loafncatting_mobile/screens/product_detail_screen.dart';
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
  @override
  Future<List<Category>> getCategories() async => <Category>[];

  @override
  Future<List<Product>> getProducts({int? categoryId, String? search}) async =>
      <Product>[];
}

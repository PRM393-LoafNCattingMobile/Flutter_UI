import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/login_screen.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

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

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Please enter your email or phone number'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}

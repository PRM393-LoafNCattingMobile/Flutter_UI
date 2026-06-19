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

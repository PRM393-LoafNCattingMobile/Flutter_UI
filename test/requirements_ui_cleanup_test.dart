import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/main.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AppStrings and AppRoutes expose the expected centralized values', () {
    expect(AppStrings.appTitle, "Loaf'NCatting");
    expect(AppStrings.signInButton, 'Sign in');
    expect(AppStrings.registerButton, 'Register');

    expect(AppRoutes.splash, '/');
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.register, '/register');
    expect(AppRoutes.home, '/home');
  });

  testWidgets('LoafApp wires centralized title and named routes into MaterialApp',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(LoafApp(api: ApiService()));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final routes = materialApp.routes;

    expect(materialApp.title, AppStrings.appTitle);
    expect(routes, isNotNull);
    expect(routes!.keys, containsAll(<String>[
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.home,
    ]));
  });

  test('listed files no longer use raw named-route literals where prohibited', () {
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

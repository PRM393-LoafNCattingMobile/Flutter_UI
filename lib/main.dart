import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_shell_screen.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/home_screen.dart';
import 'package:loafncatting_mobile/screens/login_screen.dart';
import 'package:loafncatting_mobile/screens/register_screen.dart';
import 'package:loafncatting_mobile/screens/splash_screen.dart';
import 'package:loafncatting_mobile/services/api_service.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  final api = ApiService();
  runApp(LoafApp(api: api));
}

class LoafApp extends StatelessWidget {
  const LoafApp({super.key, required this.api});
  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(api)),
        ChangeNotifierProvider(create: (_) => CatalogProvider(api)),
        ChangeNotifierProvider(create: (_) => CartProvider(api)),
        ChangeNotifierProvider(create: (_) => ReservationProvider(api)),
        ChangeNotifierProvider(create: (_) => CatProvider(api)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(api)),
        ChangeNotifierProvider(create: (_) => LocationProvider(api)),
        ChangeNotifierProvider(create: (_) => ChatProvider(api)),
        // Admin/Staff feature providers.
        ChangeNotifierProvider(create: (_) => AdminLookupsProvider(api)),
        ChangeNotifierProvider(create: (_) => AdminCatalogProvider(api)),
        ChangeNotifierProvider(create: (_) => AdminCatProvider(api)),
        ChangeNotifierProvider(create: (_) => AdminTableProvider(api)),
        ChangeNotifierProvider(create: (_) => StaffOrderProvider(api)),
        ChangeNotifierProvider(create: (_) => StaffReservationProvider(api)),
        ChangeNotifierProvider(create: (_) => AdminUserProvider(api)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(api)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        theme: buildLoafTheme(),
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.adminShell: (_) => const AdminShellScreen(),
        },
      ),
    );
  }
}

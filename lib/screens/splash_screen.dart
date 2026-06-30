import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.loadSession();
      if (!mounted) return;
      if (auth.isLoggedIn) {
        await context
            .read<CartProvider>()
            .loadForUser(auth.user!.userId, mergeLocal: false);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        auth.isLoggedIn
            ? RoleRouting.homeRouteForRole(auth.user!.roleName)
            : AppRoutes.login,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CafeSurface(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CafeIconBadge(icon: Icons.pets, size: 72),
              SizedBox(height: 18),
              Text(
                AppStrings.appTitle,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

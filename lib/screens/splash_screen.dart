import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      auth.loadSession().then((_) {
        if (!mounted) return;
        Navigator.of(context)
            .pushReplacementNamed(auth.isLoggedIn ? '/home' : '/login');
      });
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
                "Loaf'NCatting",
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

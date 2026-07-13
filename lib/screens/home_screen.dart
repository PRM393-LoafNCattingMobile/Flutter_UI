import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/cat_gallery_screen.dart';
import 'package:loafncatting_mobile/screens/menu_screen.dart';
import 'package:loafncatting_mobile/screens/more_screen.dart';
import 'package:loafncatting_mobile/screens/profile_screen.dart';
import 'package:loafncatting_mobile/screens/reservation_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 1;
  final screens = const [
    MoreScreen(),
    MenuScreen(),
    ReservationScreen(),
    CatGalleryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = _maybeProvider<AuthProvider>(context);
      final notifications = _maybeProvider<NotificationProvider>(context);
      final user = auth?.user;
      if (user == null || notifications == null) return;
      unawaited(notifications.load(user.userId));
      unawaited(notifications.startRealtime(user.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: AppStrings.homeNavLabel),
          NavigationDestination(
              icon: Icon(Icons.local_cafe_outlined),
              selectedIcon: Icon(Icons.local_cafe),
              label: AppStrings.menuNavLabel),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: AppStrings.reservationsNavLabel),
          NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              selectedIcon: Icon(Icons.pets),
              label: AppStrings.catsNavLabel),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: AppStrings.profileNavLabel),
        ],
      ),
    );
  }
}

T? _maybeProvider<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:loafncatting_mobile/widgets/store_map.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();
    final location = provider.location;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.storeLocationTitle)),
      body: CafeSurface(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? EmptyView(provider.error!)
                : location == null
                    ? const EmptyView(AppStrings.storeLocationUnavailableMessage)
                    : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      CafeHeroHeader(
                        title: location.storeName,
                        subtitle: AppStrings.storeLocationHeroSubtitle,
                        icon: Icons.location_on,
                      ),
                      StoreLocationMap(
                        latitude: location.latitude,
                        longitude: location.longitude,
                      ),
                      const SizedBox(height: 16),
                      CafeCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LocationLine(
                                icon: Icons.place_outlined,
                                text: location.address),
                            if ((location.phoneNumber ?? '').isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _LocationLine(
                                  icon: Icons.phone_outlined,
                                  text: location.phoneNumber!),
                            ],
                            if ((location.openingHours ?? '').isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _LocationLine(
                                  icon: Icons.schedule,
                                  text: location.openingHours!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          final uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text(AppStrings.openDirectionsButton),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: loafOrange),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

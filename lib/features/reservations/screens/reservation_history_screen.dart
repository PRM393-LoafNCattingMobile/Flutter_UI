import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() =>
      _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user == null) return;
      context.read<ReservationProvider>().loadHistory(user.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.reservationHistoryTitle)),
        body: CafeSurface(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ErrorView(AppStrings.checkoutLoginRequiredMessage),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (_) => false),
                    child: const Text(AppStrings.goToLoginButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reservationHistoryTitle)),
      body: CafeSurface(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.reservations.isEmpty
                ? const EmptyView(AppStrings.reservationHistoryEmptyMessage)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: provider.reservations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = provider.reservations[index];
                      return CafeCard(
                        child: Row(
                          children: [
                            const CafeIconBadge(icon: Icons.event_available),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.date} ${item.time}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(
                                      AppStrings.reservationHistoryGuestsSummary(
                                          item.tableName, item.numberOfGuests),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: loafMuted)),
                                ],
                              ),
                            ),
                            CafeInfoChip(label: item.statusName),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

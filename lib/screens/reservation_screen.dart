import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/reservation_history_screen.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final dateController = TextEditingController(
      text: DateTime.now().toIso8601String().substring(0, 10));
  final timeController = TextEditingController(text: '18:00');
  final guestController = TextEditingController(text: '2');
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  bool didSeedUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (didSeedUser) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phoneNumber;
    }
    didSeedUser = true;
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    guestController.dispose();
    nameController.dispose();
    phoneController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservationProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reservationTitle),
        actions: [
          IconButton(
              onPressed: () {
                if (auth.user == null) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (_) => false);
                  return;
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReservationHistoryScreen()));
              },
              icon: const Icon(Icons.history))
        ],
      ),
      body: CafeSurface(
        child: Builder(
          builder: (context) {
            if (auth.user == null) {
              return Center(
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
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const CafeHeroHeader(
                  title: AppStrings.reservationHeroTitle,
                  subtitle: AppStrings.reservationHeroSubtitle,
                  icon: Icons.event_available,
                ),
                _ReservationDetailsCard(
                  provider: provider,
                  dateController: dateController,
                  timeController: timeController,
                  guestController: guestController,
                  onLoadTables: () async {
                    await provider.loadAvailable(
                      dateController.text,
                      timeController.text,
                      int.tryParse(guestController.text) ?? 1,
                    );
                  },
                ),
                const SizedBox(height: 14),
                _ReservationGuestCard(
                  nameController: nameController,
                  phoneController: phoneController,
                  noteController: noteController,
                ),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(provider.error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final ok = await provider.create({
                            'userId': auth.user!.userId,
                            'date': dateController.text,
                            'time': timeController.text,
                            'guestName': nameController.text,
                            'guestPhoneNumber': phoneController.text,
                            'numberOfGuests':
                                int.tryParse(guestController.text) ?? 1,
                            'note': noteController.text,
                            'tableId': null,
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? AppStrings.reservationCreatedMessage
                                  : AppStrings.reservationFailedMessage)));
                        },
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline),
                  label: const Text(AppStrings.confirmReservationButton),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReservationDetailsCard extends StatelessWidget {
  const _ReservationDetailsCard({
    required this.provider,
    required this.dateController,
    required this.timeController,
    required this.guestController,
    required this.onLoadTables,
  });

  final ReservationProvider provider;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController guestController;
  final VoidCallback onLoadTables;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.dateLabel,
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.timeLabel,
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: guestController,
            decoration: const InputDecoration(
              labelText: AppStrings.guestCountLabel,
              prefixIcon: Icon(Icons.group_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onLoadTables,
            icon: const Icon(Icons.table_restaurant_outlined),
            label: const Text(AppStrings.loadAvailableTablesButton),
          ),
          if (provider.availableTables.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.availableTables
                    .take(4)
                    .map(
                      (table) => CafeInfoChip(
                        label: AppStrings.reservationTableOption(
                          table.tableName,
                          table.capacity,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReservationGuestCard extends StatelessWidget {
  const _ReservationGuestCard({
    required this.nameController,
    required this.phoneController,
    required this.noteController,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    return CafeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: AppStrings.guestNameLabel,
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: AppStrings.phoneNumberLabel,
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: AppStrings.noteLabel,
              prefixIcon: Icon(Icons.edit_note),
            ),
          ),
        ],
      ),
    );
  }
}

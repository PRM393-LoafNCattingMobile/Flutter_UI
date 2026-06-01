import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/reservation_history_screen.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
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
  int? tableId;

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
    nameController.text = nameController.text.isEmpty
        ? auth.user?.name ?? ''
        : nameController.text;
    phoneController.text = phoneController.text.isEmpty
        ? auth.user?.phoneNumber ?? ''
        : phoneController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReservationHistoryScreen())),
              icon: const Icon(Icons.history))
        ],
      ),
      body: CafeSurface(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const CafeHeroHeader(
              title: 'Reserve a table',
              subtitle: 'Choose a cozy spot before the cafe fills up.',
              icon: Icons.event_available,
            ),
            CafeCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: dateController,
                              decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined)))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextField(
                              controller: timeController,
                              decoration: const InputDecoration(
                                  labelText: 'Time',
                                  prefixIcon: Icon(Icons.schedule)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: guestController,
                      decoration: const InputDecoration(
                          labelText: 'Guest count',
                          prefixIcon: Icon(Icons.group_outlined)),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => provider.loadAvailable(
                        dateController.text,
                        timeController.text,
                        int.tryParse(guestController.text) ?? 1),
                    icon: const Icon(Icons.table_restaurant_outlined),
                    label: const Text('Load available tables'),
                  ),
                  if (provider.availableTables.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: tableId,
                      decoration: const InputDecoration(
                          labelText: 'Table',
                          prefixIcon: Icon(Icons.chair_outlined)),
                      items: provider.availableTables
                          .map((table) => DropdownMenuItem(
                              value: table.tableId,
                              child: Text(
                                  '${table.tableName} - ${table.capacity} guests')))
                          .toList(),
                      onChanged: (value) => setState(() => tableId = value),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            CafeCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'Guest name',
                          prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_outlined))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                          labelText: 'Note',
                          prefixIcon: Icon(Icons.edit_note))),
                ],
              ),
            ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(provider.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: provider.isLoading || tableId == null
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
                        'tableId': tableId,
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok
                              ? 'Reservation created'
                              : 'Reservation failed')));
                    },
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Reservation'),
            ),
          ],
        ),
      ),
    );
  }
}

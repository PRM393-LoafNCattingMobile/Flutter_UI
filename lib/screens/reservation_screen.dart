import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/screens/reservation_history_screen.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final guestController = TextEditingController(text: '2');
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final noteController = TextEditingController();
  bool didSeedUser = false;

  @override
  void initState() {
    super.initState();
    _seedInitialReservationDateTime();
  }

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

  void _seedInitialReservationDateTime() {
    var date = _dateOnly(DateTime.now());
    var slots = _availableTimeSlotsForDate(date);
    if (slots.isEmpty) {
      date = date.add(const Duration(days: 1));
      slots = _availableTimeSlotsForDate(date);
    }

    dateController.text = _formatDate(date);
    timeController.text = _preferredTimeSlot(slots);
  }

  DateTime _selectedDate() =>
      _parseDate(dateController.text) ?? _dateOnly(DateTime.now());

  Future<void> _pickDate() async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate().isBefore(today) ? today : _selectedDate(),
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked == null || !mounted) return;

    final date = _dateOnly(picked);
    final slots = _availableTimeSlotsForDate(date);
    setState(() {
      dateController.text = _formatDate(date);
      timeController.text = slots.contains(timeController.text)
          ? timeController.text
          : _preferredTimeSlot(slots);
    });
  }

  bool _ensureFutureReservationDateTime() {
    final date = _selectedDate();
    final slots = _availableTimeSlotsForDate(date);
    if (timeController.text.isEmpty || !slots.contains(timeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khung giờ đặt bàn trong tương lai.'),
        ),
      );
      setState(() => timeController.text = _preferredTimeSlot(slots));
      return false;
    }

    return true;
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

            final selectedDate = _selectedDate();
            final availableTimeSlots = _availableTimeSlotsForDate(selectedDate);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const CafeHeroHeader(
                  title: AppStrings.reservationHeroTitle,
                  subtitle: AppStrings.reservationHeroSubtitle,
                  icon: Icons.event_available,
                ),
                _ReservationDetailsCard(
                  dateController: dateController,
                  guestController: guestController,
                  timeSlots: availableTimeSlots,
                  selectedTime: availableTimeSlots.contains(timeController.text)
                      ? timeController.text
                      : null,
                  onDateTap: _pickDate,
                  onTimeChanged: (value) {
                    if (value == null) return;
                    setState(() => timeController.text = value);
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
                  onPressed: provider.isLoading || timeController.text.isEmpty
                      ? null
                      : () async {
                          if (!_ensureFutureReservationDateTime()) return;
                          final phoneError =
                              CafeValidators.phone(phoneController.text);
                          if (phoneError != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(phoneError)),
                            );
                            return;
                          }
                          final ok = await provider.create({
                            'userId': auth.user!.userId,
                            'date': dateController.text,
                            'time': timeController.text,
                            'guestName': nameController.text,
                            'guestPhoneNumber': phoneController.text.trim(),
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

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime? _parseDate(String value) {
  try {
    final parts = value.split('-').map(int.parse).toList();
    if (parts.length != 3) return null;
    return DateTime(parts[0], parts[1], parts[2]);
  } catch (_) {
    return null;
  }
}

DateTime _slotDateTime(DateTime date, String slot) {
  final parts = slot.split(':').map(int.parse).toList();
  return DateTime(date.year, date.month, date.day, parts[0], parts[1]);
}

List<String> _availableTimeSlotsForDate(DateTime date) {
  final now = DateTime.now();
  final slots = <String>[];
  for (var minutes = 8 * 60; minutes <= 21 * 60; minutes += 30) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final slot = '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
    if (_slotDateTime(date, slot).isAfter(now)) {
      slots.add(slot);
    }
  }
  return slots;
}

String _preferredTimeSlot(List<String> slots) {
  if (slots.contains('18:00')) return '18:00';
  return slots.isEmpty ? '' : slots.first;
}

class _ReservationDetailsCard extends StatelessWidget {
  const _ReservationDetailsCard({
    required this.dateController,
    required this.guestController,
    required this.timeSlots,
    required this.selectedTime,
    required this.onDateTap,
    required this.onTimeChanged,
  });

  final TextEditingController dateController;
  final TextEditingController guestController;
  final List<String> timeSlots;
  final String? selectedTime;
  final VoidCallback onDateTap;
  final ValueChanged<String?> onTimeChanged;

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
                  readOnly: true,
                  onTap: onDateTap,
                  decoration: const InputDecoration(
                    labelText: AppStrings.dateLabel,
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedTime,
                  isExpanded: true,
                  items: timeSlots
                      .map(
                        (slot) => DropdownMenuItem(
                          value: slot,
                          child: Text(slot),
                        ),
                      )
                      .toList(),
                  onChanged: timeSlots.isEmpty ? null : onTimeChanged,
                  decoration: const InputDecoration(
                    labelText: AppStrings.timeLabel,
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  hint: const Text('Hết khung giờ'),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';
import 'package:loafncatting_mobile/features/admin/widgets/status_picker.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<StaffReservationProvider>().load();
    });
  }

  Future<void> _updateStatus(Reservation reservation) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    final provider = context.read<StaffReservationProvider>();
    if (lookups == null) return;
    final options =
        _nextReservationStatusOptions(reservation, lookups.reservationStatuses);
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.adminReservationFinalStatusMessage)),
      );
      return;
    }

    final statusId = await showStatusPicker(
      context,
      title: AppStrings.adminUpdateStatusTitle,
      options: options,
      currentName: reservation.statusName,
    );
    if (statusId == null || !mounted) return;

    final ok = await provider.updateStatus(reservation.reservationId, statusId);
    if (ok && mounted) {
      final tables = _maybeProvider<AdminTableProvider>(context);
      if (tables != null) {
        unawaited(tables.load());
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminStatusUpdatedMessage
          : (provider.error ?? AppStrings.adminStatusUpdatedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffReservationProvider>();
    final lookups = context.watch<AdminLookupsProvider>().lookups;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminReservationsTitle)),
      body: CafeSurface(
        child: Column(
          children: [
            AdminStatusFilterBar(
              options: lookups?.reservationStatuses ?? const [],
              selectedId: provider.statusFilter,
              selectedDate: provider.dateFilter,
              onChanged: provider.applyStatusFilter,
              onDateChanged: provider.applyDateFilter,
              onReset: provider.clearFilters,
            ),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StaffReservationProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    if (provider.reservations.isEmpty) {
      return EmptyView(provider.hasFilters
          ? 'Kh\u00f4ng t\u00ecm th\u1ea5y l\u01b0\u1ee3t \u0111\u1eb7t b\u00e0n ph\u00f9 h\u1ee3p.'
          : AppStrings.adminReservationsEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.reservations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _ReservationCard(
          reservation: provider.reservations[index],
          onUpdateStatus: () => _updateStatus(provider.reservations[index]),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onUpdateStatus,
  });
  final Reservation reservation;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = reservation.note?.trim();
    return CafeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${reservation.date} ${reservation.time}',
                    style: theme.textTheme.titleMedium),
              ),
              CafeInfoChip(label: reservation.statusName),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.adminReservationGuestLabel(
                reservation.guestName, reservation.guestPhoneNumber),
            style: theme.textTheme.bodyMedium?.copyWith(color: loafMuted),
          ),
          Text(
            AppStrings.reservationHistoryGuestsSummary(
                reservation.tableName, reservation.numberOfGuests),
            style: theme.textTheme.bodySmall?.copyWith(color: loafMuted),
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onUpdateStatus,
              icon: const Icon(Icons.sync),
              label: const Text(AppStrings.adminUpdateStatusButton),
            ),
          ),
        ],
      ),
    );
  }
}

List<LookupItem> _nextReservationStatusOptions(
  Reservation reservation,
  List<LookupItem> statuses,
) {
  final names = switch (reservation.statusName) {
    'Đang chờ' => ['Đã xác nhận', 'Đã hủy'],
    'Đã xác nhận' => ['Hoàn thành', 'Đã hủy', 'Không đến'],
    _ => const <String>[],
  };
  return statuses.where((status) => names.contains(status.name)).toList();
}

T? _maybeProvider<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}

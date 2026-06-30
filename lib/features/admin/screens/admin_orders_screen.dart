import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';
import 'package:loafncatting_mobile/features/admin/widgets/status_picker.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<StaffOrderProvider>().load();
    });
  }

  Future<void> _updateStatus(Order order) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    final provider = context.read<StaffOrderProvider>();
    if (lookups == null) return;

    final statusId = await showStatusPicker(
      context,
      title: AppStrings.adminUpdateStatusTitle,
      options: lookups.orderStatuses,
      currentName: order.statusName,
    );
    if (statusId == null || !mounted) return;

    final ok = await provider.updateStatus(order.orderId, statusId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminStatusUpdatedMessage
          : (provider.error ?? AppStrings.adminStatusUpdatedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffOrderProvider>();
    final lookups = context.watch<AdminLookupsProvider>().lookups;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminOrdersTitle)),
      body: CafeSurface(
        child: Column(
          children: [
            AdminStatusFilterBar(
              options: lookups?.orderStatuses ?? const [],
              selectedId: provider.statusFilter,
              onChanged: (statusId) =>
                  provider.applyFilters(statusId: statusId),
            ),
            Expanded(
              child: _buildBody(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(StaffOrderProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    if (provider.orders.isEmpty) {
      return const EmptyView(AppStrings.adminOrdersEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _OrderCard(
          order: provider.orders[index],
          onUpdateStatus: () => _updateStatus(provider.orders[index]),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onUpdateStatus});
  final Order order;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CafeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.adminOrderCodeLabel(order.orderId),
                    style: theme.textTheme.titleMedium),
              ),
              Text(money(order.totalPrice),
                  style: moneyTextStyle(theme.textTheme.titleMedium,
                      color: loafOrange, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text(AppStrings.adminOrderCustomerLabel(order.customerName ?? '-'),
              style: theme.textTheme.bodyMedium?.copyWith(color: loafMuted)),
          Text(formatAdminDateTime(order.orderDate),
              style: theme.textTheme.bodySmall?.copyWith(color: loafMuted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CafeInfoChip(label: order.statusName),
              CafeInfoChip(
                  label:
                      '${AppStrings.adminPaymentStatusPrefix}${order.paymentStatus}'),
            ],
          ),
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

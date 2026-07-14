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
    final options = _nextOrderStatusOptions(order, lookups.orderStatuses);
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(AppStrings.adminNoNextStatusMessage)),
      );
      return;
    }

    final statusId = await showStatusPicker(
      context,
      title: AppStrings.adminUpdateStatusTitle,
      options: options,
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

  Future<void> _openOrderDetail(Order order) async {
    final provider = context.read<StaffOrderProvider>();
    final detail = await provider.loadOrderDetail(order.orderId);
    if (!mounted) return;
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? AppStrings.adminOrderDetailFallbackError),
      ));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _OrderDetailSheet(
        order: detail,
        statusOptions:
            context.read<AdminLookupsProvider>().lookups?.orderStatuses ??
                const [],
        onUpdateStatus: (statusId) async {
          final ok = await provider.updateStatus(detail.orderId, statusId);
          if (!mounted || !sheetContext.mounted) return;
          Navigator.pop(sheetContext);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok
                ? AppStrings.adminStatusUpdatedMessage
                : (provider.error ?? AppStrings.adminStatusUpdatedMessage)),
          ));
        },
      ),
    );
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
              selectedDate: provider.dateFilter,
              onChanged: provider.applyStatusFilter,
              onDateChanged: provider.applyDateFilter,
              onReset: provider.clearFilters,
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
      return EmptyView(provider.hasFilters
          ? 'Kh\u00f4ng t\u00ecm th\u1ea5y \u0111\u01a1n h\u00e0ng ph\u00f9 h\u1ee3p.'
          : AppStrings.adminOrdersEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _OrderCard(
          order: provider.orders[index],
          onOpenDetail: () => _openOrderDetail(provider.orders[index]),
          onUpdateStatus: () => _updateStatus(provider.orders[index]),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onOpenDetail,
    required this.onUpdateStatus,
  });
  final Order order;
  final VoidCallback onOpenDetail;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPrepare = _isPaid(order) || order.statusName != 'Đang chờ';
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
          if (!canPrepare) ...[
            const SizedBox(height: 10),
            Text(
              'Đơn chuyển khoản chưa thanh toán nên chưa thể bắt đầu nấu.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpenDetail,
                  icon: const Icon(Icons.restaurant_menu_outlined),
                  label: const Text(AppStrings.adminCookingDetailButton),
                ),
                OutlinedButton.icon(
                  onPressed: onUpdateStatus,
                  icon: const Icon(Icons.sync),
                  label: const Text(AppStrings.adminUpdateStatusButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({
    required this.order,
    required this.statusOptions,
    required this.onUpdateStatus,
  });

  final Order order;
  final List<LookupItem> statusOptions;
  final Future<void> Function(int statusId) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextStatuses = _nextOrderStatusOptions(order, statusOptions);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.adminOrderCodeLabel(order.orderId),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Text(
                  money(order.totalPrice),
                  style: moneyTextStyle(
                    theme.textTheme.titleMedium,
                    color: loafOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.adminOrderCustomerLabel(order.customerName ?? '-'),
              style: theme.textTheme.bodyMedium?.copyWith(color: loafMuted),
            ),
            Text(
              formatAdminDateTime(order.orderDate),
              style: theme.textTheme.bodySmall?.copyWith(color: loafMuted),
            ),
            const SizedBox(height: 12),
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
            if (!_isPaid(order)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Chờ khách hoàn tất thanh toán trước khi bắt đầu chuẩn bị đơn.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(AppStrings.adminItemsToPrepareTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (order.items.isEmpty)
              Text(AppStrings.adminOrderHasNoItemsMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(color: loafMuted))
            else
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: loafBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(item.productName),
                      subtitle: Text(money(item.unitPrice)),
                      trailing: Text(
                        'x${item.quantity}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (nextStatuses.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: nextStatuses
                    .map(
                      (status) => FilledButton.icon(
                        onPressed: () => onUpdateStatus(status.id),
                        icon: Icon(_iconForOrderStatus(status.name)),
                        label: Text(status.name),
                      ),
                    )
                    .toList(),
              )
            else
              Text(
                'Đơn đã ở trạng thái cuối.',
                style: theme.textTheme.bodySmall?.copyWith(color: loafMuted),
              ),
          ],
        ),
      ),
    );
  }
}

bool _isPaid(Order order) => order.paymentStatus == 'Đã thanh toán';

List<LookupItem> _nextOrderStatusOptions(
  Order order,
  List<LookupItem> statuses,
) {
  final names = switch (order.statusName) {
    'Đang chờ' => _isPaid(order) ? ['Đang chuẩn bị', 'Đã hủy'] : ['Đã hủy'],
    'Đang chuẩn bị' => ['Hoàn thành', 'Đã hủy'],
    _ => const <String>[],
  };
  return statuses.where((status) => names.contains(status.name)).toList();
}

IconData _iconForOrderStatus(String statusName) {
  return switch (statusName) {
    'Đang chuẩn bị' => Icons.soup_kitchen_outlined,
    'Hoàn thành' => Icons.check_circle_outline,
    'Đã hủy' => Icons.cancel_outlined,
    _ => Icons.sync,
  };
}

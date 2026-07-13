import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_routes.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthProvider>().user;
      if (user == null) return;
      context.read<OrderHistoryProvider>().load(user.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderHistoryProvider>();
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.orderHistoryTitle)),
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
                      context,
                      AppRoutes.login,
                      (_) => false,
                    ),
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
      appBar: AppBar(title: const Text(AppStrings.orderHistoryTitle)),
      body: CafeSurface(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? ErrorView(
                    provider.error!,
                    onRetry: () => provider.load(user.userId),
                  )
                : provider.orders.isEmpty
                    ? const EmptyView(AppStrings.orderHistoryEmptyMessage)
                    : RefreshIndicator(
                        onRefresh: () => provider.load(user.userId),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: provider.orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) =>
                              _OrderHistoryCard(order: provider.orders[index]),
                        ),
                      ),
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CafeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CafeIconBadge(icon: Icons.receipt_long_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn #${order.orderId}',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      _formatOrderDate(order.orderDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: loafMuted,
                      ),
                    ),
                  ],
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CafeInfoChip(
                label: order.statusName,
                color: _statusColor(order.statusName),
              ),
              CafeInfoChip(
                label: order.paymentStatus,
                color: _paymentColor(order.paymentStatus),
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: loafMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      money(item.subtotal),
                      style: moneyTextStyle(
                        theme.textTheme.titleSmall,
                        color: loafOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatOrderDate(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  final local = value.toLocal();
  return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

Color _statusColor(String statusName) {
  return switch (statusName) {
    'Đã hủy' => const Color(0xFFC2412D),
    'Hoàn thành' => loafSuccess,
    'Đang chuẩn bị' => loafDeepOrange,
    _ => loafOrange,
  };
}

Color _paymentColor(String paymentStatus) {
  return switch (paymentStatus) {
    'Đã thanh toán' => loafSuccess,
    'Đã hủy' => const Color(0xFFC2412D),
    _ => loafOrange,
  };
}

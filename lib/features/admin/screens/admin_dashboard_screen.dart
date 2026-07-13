import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

enum AdminDashboardMetric {
  pendingOrders,
  todayReservations,
  lowStockProducts,
  catsNotWorking,
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, this.onMetricSelected});

  final ValueChanged<AdminDashboardMetric>? onMetricSelected;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminDashboardTitle)),
      body: CafeSurface(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(DashboardProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    final onMetricSelected = widget.onMetricSelected;
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const CafeHeroHeader(
            title: 'Tổng quan vận hành',
            subtitle: 'Số liệu nhanh cho ca làm việc hôm nay.',
            icon: Icons.insights,
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatCard(
                icon: Icons.receipt_long,
                value: provider.pendingOrders,
                label: AppStrings.adminDashboardPendingOrders,
                onTap: onMetricSelected == null
                    ? null
                    : () =>
                        onMetricSelected(AdminDashboardMetric.pendingOrders),
              ),
              _StatCard(
                icon: Icons.event_available,
                value: provider.todayReservations,
                label: AppStrings.adminDashboardTodayReservations,
                onTap: onMetricSelected == null
                    ? null
                    : () => onMetricSelected(
                        AdminDashboardMetric.todayReservations),
              ),
              _StatCard(
                icon: Icons.inventory_2_outlined,
                value: provider.lowStockProducts,
                label: AppStrings.adminDashboardLowStock,
                onTap: onMetricSelected == null
                    ? null
                    : () =>
                        onMetricSelected(AdminDashboardMetric.lowStockProducts),
              ),
              _StatCard(
                icon: Icons.pets,
                value: provider.catsNotWorking,
                label: AppStrings.adminDashboardCatsNotWorking,
                onTap: onMetricSelected == null
                    ? null
                    : () =>
                        onMetricSelected(AdminDashboardMetric.catsNotWorking),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: CafeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CafeIconBadge(icon: icon),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(Icons.chevron_right, color: loafMuted, size: 22),
                ],
              ),
              Text('$value',
                  style: theme.textTheme.headlineMedium?.copyWith(
                      color: loafOrange, fontWeight: FontWeight.w900)),
              Text(label,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: loafMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

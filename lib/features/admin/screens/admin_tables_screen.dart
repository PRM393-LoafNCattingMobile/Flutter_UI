import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/status_picker.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

int? _idForName(List<LookupItem> options, String? name) {
  for (final option in options) {
    if (option.name == name) return option.id;
  }
  return null;
}

class AdminTablesScreen extends StatefulWidget {
  const AdminTablesScreen({super.key});

  @override
  State<AdminTablesScreen> createState() => _AdminTablesScreenState();
}

class _AdminTablesScreenState extends State<AdminTablesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<AdminTableProvider>().load();
    });
  }

  bool get _canEditTables =>
      RoleRouting.isAdmin(context.read<AuthProvider>().user?.roleName);

  bool get _canUpdateStatus =>
      RoleRouting.isStaffOrAdmin(context.read<AuthProvider>().user?.roleName);

  Future<void> _openForm(CafeTable? table) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    if (lookups == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTableFormScreen(
          table: table,
          statuses: lookups.tableStatuses,
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.adminSavedMessage)));
    }
  }

  Future<void> _delete(CafeTable table) async {
    final provider = context.read<AdminTableProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.adminDeleteConfirmTitle),
        content: const Text(AppStrings.adminDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppStrings.adminCancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppStrings.adminDeleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await provider.deleteTable(table.tableId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminDeletedMessage
          : (provider.error ?? AppStrings.adminDeletedMessage)),
    ));
  }

  Future<void> _updateStatus(CafeTable table) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    final provider = context.read<AdminTableProvider>();
    if (lookups == null) return;
    final statusId = await showStatusPicker(
      context,
      title: AppStrings.adminUpdateStatusTitle,
      options: lookups.tableStatuses,
      currentName: table.statusName,
    );
    if (statusId == null || !mounted) return;
    final ok = await provider.updateStatus(table.tableId, statusId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminStatusUpdatedMessage
          : (provider.error ?? AppStrings.adminStatusUpdatedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminTableProvider>();
    final canEditTables = _canEditTables;
    final canUpdateStatus = _canUpdateStatus;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminTablesTitle)),
      floatingActionButton: canEditTables
          ? FloatingActionButton(
              onPressed: () => _openForm(null),
              child: const Icon(Icons.add),
            )
          : null,
      body: CafeSurface(
          child: _buildBody(provider, canEditTables, canUpdateStatus)),
    );
  }

  Widget _buildBody(
    AdminTableProvider provider,
    bool canEditTables,
    bool canUpdateStatus,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    if (provider.tables.isEmpty) {
      return const EmptyView(AppStrings.adminTablesEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _TableMapSection(
            tables: provider.tables,
            canUpdateStatus: canUpdateStatus,
            onTapTable: _updateStatus,
          ),
          const SizedBox(height: 14),
          ...provider.tables.map((table) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CafeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CafeIconBadge(icon: Icons.table_restaurant_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(table.tableName,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            AppStrings.reservationTableOption(
                                table.area ?? '-', table.capacity),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: loafMuted),
                          ),
                        ],
                      ),
                    ),
                    CafeInfoChip(label: table.statusName),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      if (canUpdateStatus)
                        OutlinedButton.icon(
                          onPressed: () => _updateStatus(table),
                          icon: const Icon(Icons.sync),
                          label:
                              const Text(AppStrings.adminUpdateStatusButton),
                        ),
                      if (canEditTables) ...[
                        TextButton.icon(
                          onPressed: () => _openForm(table),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(AppStrings.adminSaveButton),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(table),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TableMapSection extends StatelessWidget {
  const _TableMapSection({
    required this.tables,
    required this.canUpdateStatus,
    required this.onTapTable,
  });

  final List<CafeTable> tables;
  final bool canUpdateStatus;
  final ValueChanged<CafeTable> onTapTable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = <String, List<CafeTable>>{};
    for (final table in tables) {
      grouped.putIfAbsent(table.area?.trim().isNotEmpty == true
          ? table.area!.trim()
          : 'Khu chung', () => []).add(table);
    }

    return CafeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CafeIconBadge(icon: Icons.grid_view_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Sơ đồ bàn',
                    style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...grouped.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: loafMuted)),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 560 ? 4 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.55,
                        ),
                        itemBuilder: (_, index) {
                          final table = entry.value[index];
                          return _TableMapTile(
                            table: table,
                            onTap: canUpdateStatus
                                ? () => onTapTable(table)
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableMapTile extends StatelessWidget {
  const _TableMapTile({required this.table, this.onTap});

  final CafeTable table;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(table.statusName);
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.table_restaurant_outlined, color: color, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      table.tableName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              Text('${table.capacity} khách',
                  style: theme.textTheme.bodySmall?.copyWith(color: loafMuted)),
              Text(
                table.statusName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String statusName) {
  return switch (statusName) {
    'Trống' => const Color(0xFF2E7D32),
    'Đã đặt' => const Color(0xFFEF6C00),
    'Đang sử dụng' => loafOrange,
    'Bảo trì' => const Color(0xFFC62828),
    _ => loafMuted,
  };
}

class AdminTableFormScreen extends StatefulWidget {
  const AdminTableFormScreen({
    super.key,
    this.table,
    required this.statuses,
  });

  final CafeTable? table;
  final List<LookupItem> statuses;

  @override
  State<AdminTableFormScreen> createState() => _AdminTableFormScreenState();
}

class _AdminTableFormScreenState extends State<AdminTableFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController capacityController;
  late final TextEditingController areaController;
  late final TextEditingController descriptionController;
  int? statusId;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final table = widget.table;
    nameController = TextEditingController(text: table?.tableName ?? '');
    capacityController =
        TextEditingController(text: table?.capacity.toString() ?? '');
    areaController = TextEditingController(text: table?.area ?? '');
    descriptionController =
        TextEditingController(text: table?.description ?? '');
    statusId = _idForName(widget.statuses, table?.statusName) ??
        (widget.statuses.isNotEmpty ? widget.statuses.first.id : null);
  }

  @override
  void dispose() {
    nameController.dispose();
    capacityController.dispose();
    areaController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (statusId == null) return;
    setState(() {
      saving = true;
      error = null;
    });
    final body = {
      'tableName': nameController.text.trim(),
      'capacity': int.parse(capacityController.text.trim()),
      'area': areaController.text.trim().isEmpty
          ? null
          : areaController.text.trim(),
      'description': descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      'tableStatusId': statusId,
    };
    final provider = context.read<AdminTableProvider>();
    final ok = await provider.saveTable(body, id: widget.table?.tableId);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        saving = false;
        error = provider.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table == null
            ? AppStrings.adminAddTableTitle
            : AppStrings.adminEditTableTitle),
      ),
      body: CafeSurface(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              CafeTextFormField(
                controller: nameController,
                labelText: AppStrings.tableNameLabel,
                validator: (value) => CafeValidators.requiredField(
                    value, AppStrings.tableNameLabel),
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: capacityController,
                labelText: AppStrings.tableCapacityLabel,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return AppStrings.adminInvalidNumberMessage;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: areaController,
                labelText: AppStrings.tableAreaLabel,
              ),
              const SizedBox(height: 12),
              CafeTextFormField(
                controller: descriptionController,
                labelText: AppStrings.tableDescriptionLabel,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: statusId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.tableStatusLabel,
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: widget.statuses
                    .map((status) => DropdownMenuItem(
                        value: status.id, child: Text(status.name)))
                    .toList(),
                onChanged: (value) => setState(() => statusId = value),
                validator: (value) =>
                    value == null ? AppStrings.adminFieldRequiredMessage : null,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: const Text(AppStrings.adminSaveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

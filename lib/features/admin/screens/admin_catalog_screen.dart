import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_categories_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_product_form_screen.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<AdminCatalogProvider>().load();
    });
  }

  bool get _canManage =>
      RoleRouting.isStaffOrAdmin(context.read<AuthProvider>().user?.roleName);

  Future<void> _openProductForm(Product? product) async {
    final lookups = context.read<AdminLookupsProvider>().lookups;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(
          product: product,
          categories: lookups?.categories ?? const [],
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.adminSavedMessage)));
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final provider = context.read<AdminCatalogProvider>();
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
    final ok = await provider.deleteProduct(product.productId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminDeletedMessage
          : (provider.error ?? AppStrings.adminDeletedMessage)),
    ));
  }

  Future<void> _editAvailability(Product product) async {
    final provider = context.read<AdminCatalogProvider>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AvailabilityDialog(product: product),
    );
    if (result == null) return;
    final ok = await provider.updateAvailability(
        product.productId, result['stock'] as int, result['available'] as bool);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? AppStrings.adminSavedMessage
          : (provider.error ?? AppStrings.adminSavedMessage)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCatalogProvider>();
    final canManage = _canManage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminCatalogTitle),
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.category_outlined),
              tooltip: AppStrings.adminManageCategoriesTitle,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminCategoriesScreen()),
              ),
            ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => _openProductForm(null),
              child: const Icon(Icons.add),
            )
          : null,
      body: CafeSurface(child: _buildBody(provider, canManage)),
    );
  }

  Widget _buildBody(AdminCatalogProvider provider, bool canManage) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return ErrorView(provider.error!, onRetry: provider.load);
    }
    if (provider.products.isEmpty) {
      return const EmptyView(AppStrings.adminCatalogEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: provider.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final product = provider.products[index];
          return _ProductCard(
            product: product,
            canManage: canManage,
            onEdit: () => _openProductForm(product),
            onDelete: () => _deleteProduct(product),
            onEditAvailability: () => _editAvailability(product),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
    required this.onEditAvailability,
  });

  final Product product;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onEditAvailability;

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
                  child: Text(product.name,
                      style: theme.textTheme.titleMedium)),
              Text(money(product.displayPrice),
                  style: moneyTextStyle(theme.textTheme.titleMedium,
                      color: loafOrange, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text(product.categoryName,
              style: theme.textTheme.bodySmall?.copyWith(color: loafMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CafeInfoChip(label: AppStrings.stockCountLabel(product.unitInStock)),
              CafeInfoChip(
                  label: product.isAvailable
                      ? AppStrings.inStockLabel
                      : AppStrings.outOfStockLabel),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: canManage
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(AppStrings.adminSaveButton),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: onEditAvailability,
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text(AppStrings.adminUpdateStockTitle),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityDialog extends StatefulWidget {
  const _AvailabilityDialog({required this.product});
  final Product product;

  @override
  State<_AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<_AvailabilityDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController stockController;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    stockController =
        TextEditingController(text: widget.product.unitInStock.toString());
    isAvailable = widget.product.isAvailable;
  }

  @override
  void dispose() {
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.adminUpdateStockTitle),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CafeTextFormField(
              controller: stockController,
              labelText: AppStrings.productStockLabel,
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = int.tryParse((value ?? '').trim());
                if (parsed == null || parsed < 0) {
                  return AppStrings.adminInvalidNumberMessage;
                }
                return null;
              },
            ),
            SwitchListTile(
              value: isAvailable,
              title: const Text(AppStrings.productAvailableLabel),
              onChanged: (value) => setState(() => isAvailable = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.adminCancelButton),
        ),
        FilledButton(
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            Navigator.pop(context, {
              'stock': int.parse(stockController.text.trim()),
              'available': isAvailable,
            });
          },
          child: const Text(AppStrings.adminSaveButton),
        ),
      ],
    );
  }
}

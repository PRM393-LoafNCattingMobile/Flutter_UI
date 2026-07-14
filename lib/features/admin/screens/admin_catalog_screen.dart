import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/admin_routing.dart';
import 'package:loafncatting_mobile/features/admin/providers/admin_providers.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_categories_screen.dart';
import 'package:loafncatting_mobile/features/admin/screens/admin_product_form_screen.dart';
import 'package:loafncatting_mobile/models/models.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';
import 'package:loafncatting_mobile/widgets/cafe_form_fields.dart';
import 'package:loafncatting_mobile/widgets/cafe_widgets.dart';
import 'package:loafncatting_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';
part '../widgets/admin_catalog_widgets.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminLookupsProvider>().load();
      context.read<AdminCatalogProvider>().load();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    final confirmed = await showAdminDeleteConfirmDialog(context);
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
      body: CafeSurface(
        child: Column(
          children: [
            _AdminCatalogFilterHeader(
              provider: provider,
              searchController: searchController,
              onOpenFilters: () => _showCatalogFilters(context, provider),
              onResetFilters: () {
                searchController.clear();
                provider.resetProductFilters();
              },
              onClearSearch: () {
                searchController.clear();
                provider.clearSearchFilter();
              },
            ),
            Expanded(child: _buildBody(provider, canManage)),
          ],
        ),
      ),
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
      return EmptyView(provider.hasProductFilters
          ? 'Kh\u00f4ng t\u00ecm th\u1ea5y s\u1ea3n ph\u1ea9m n\u00e0o.'
          : AppStrings.adminCatalogEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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

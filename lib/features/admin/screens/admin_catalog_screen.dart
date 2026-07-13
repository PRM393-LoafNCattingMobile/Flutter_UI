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

class _AdminCatalogFilterHeader extends StatelessWidget {
  const _AdminCatalogFilterHeader({
    required this.provider,
    required this.searchController,
    required this.onOpenFilters,
    required this.onResetFilters,
    required this.onClearSearch,
  });

  final AdminCatalogProvider provider;
  final TextEditingController searchController;
  final VoidCallback onOpenFilters;
  final VoidCallback onResetFilters;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: AppStrings.menuSearchHint,
                  ),
                  onSubmitted: (value) => provider.applySearch(value.trim()),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: loafBorder),
                      ),
                      child: Center(
                        child: IconButton(
                          onPressed: onOpenFilters,
                          icon: const Icon(Icons.tune),
                        ),
                      ),
                    ),
                    if (provider.hasProductFilters)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: loafOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (provider.categories.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.apps_outlined, size: 17),
                  label: const Text(AppStrings.allCategoryLabel),
                  selected: provider.selectedCategoryId == null,
                  onSelected: (_) => provider.applyCategoryFilter(null),
                ),
                const SizedBox(width: 8),
                ...provider.categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: const Icon(Icons.local_cafe_outlined, size: 17),
                      label: Text(category.name),
                      selected:
                          provider.selectedCategoryId == category.categoryId,
                      onSelected: (_) =>
                          provider.applyCategoryFilter(category.categoryId),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (provider.hasProductFilters)
          _AdminProductActiveFilters(
            provider: provider,
            onResetFilters: onResetFilters,
            onClearSearch: onClearSearch,
          ),
      ],
    );
  }
}

class _AdminProductActiveFilters extends StatelessWidget {
  const _AdminProductActiveFilters({
    required this.provider,
    required this.onResetFilters,
    required this.onClearSearch,
  });

  final AdminCatalogProvider provider;
  final VoidCallback onResetFilters;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    String? selectedCategory;
    for (final category in provider.categories) {
      if (category.categoryId == provider.selectedCategoryId) {
        selectedCategory = category.name;
        break;
      }
    }

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (provider.search.trim().isNotEmpty)
            _ActiveFilterChip(
              label: 'T\u00ecm: ${provider.search.trim()}',
              onDeleted: onClearSearch,
            ),
          if (selectedCategory != null)
            _ActiveFilterChip(
              label: selectedCategory,
              onDeleted: provider.clearCategoryFilter,
            ),
          if (provider.availabilityFilter ==
              ProductAvailabilityFilter.availableOnly)
            _ActiveFilterChip(
              label: AppStrings.inStockLabel,
              onDeleted: provider.clearAvailabilityFilter,
            ),
          if (provider.hasPriceFilter)
            _ActiveFilterChip(
              label: _priceRangeLabel(
                provider.priceFilterMin,
                provider.priceFilterMax,
              ),
              onDeleted: provider.clearPriceRangeFilter,
            ),
          if (provider.sortOption != ProductSortOption.defaultOrder)
            _ActiveFilterChip(
              label: _sortOptionLabel(provider.sortOption),
              onDeleted: provider.clearSortFilter,
            ),
          if (provider.discountedOnly)
            _ActiveFilterChip(
              label: 'Gi\u1ea3m gi\u00e1',
              onDeleted: provider.clearDiscountFilter,
            ),
          TextButton(
            onPressed: onResetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 16),
      ),
    );
  }
}

Future<void> _showCatalogFilters(
  BuildContext context,
  AdminCatalogProvider provider,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CatalogFilterSheet(provider: provider),
  );
}

class _CatalogFilterSheet extends StatefulWidget {
  const _CatalogFilterSheet({required this.provider});

  final AdminCatalogProvider provider;

  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  late ProductAvailabilityFilter availability;
  late RangeValues priceRange;
  late ProductSortOption sortOption;
  late bool discountedOnly;

  @override
  void initState() {
    super.initState();
    availability = widget.provider.availabilityFilter;
    priceRange = RangeValues(
      widget.provider.priceFilterMin,
      widget.provider.priceFilterMax,
    );
    sortOption = widget.provider.sortOption;
    discountedOnly = widget.provider.discountedOnly;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: loafBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text('B\u1ed9 l\u1ecdc',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: _resetDraft,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FilterSection(
              title: 'T\u00ecnh tr\u1ea1ng',
              children: [
                _FilterChoice(
                  label: AppStrings.allCategoryLabel,
                  selected: availability == ProductAvailabilityFilter.all,
                  onSelected: () => setState(
                      () => availability = ProductAvailabilityFilter.all),
                ),
                _FilterChoice(
                  label: AppStrings.inStockLabel,
                  selected:
                      availability == ProductAvailabilityFilter.availableOnly,
                  onSelected: () => setState(() =>
                      availability = ProductAvailabilityFilter.availableOnly),
                ),
              ],
            ),
            _FilterSection(
              title: 'Gi\u00e1',
              wrapChildren: false,
              children: [
                _PriceRangeSlider(
                  values: priceRange,
                  min: widget.provider.priceFilterFloor,
                  max: widget.provider.priceFilterCeiling,
                  onChanged: (values) => setState(() => priceRange = values),
                ),
              ],
            ),
            _FilterSection(
              title: 'S\u1eafp x\u1ebfp',
              children: ProductSortOption.values
                  .map(
                    (option) => _FilterChoice(
                      label: _sortOptionLabel(option),
                      selected: sortOption == option,
                      onSelected: () => setState(() => sortOption = option),
                    ),
                  )
                  .toList(),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: loafOrange,
              title: const Text('Ch\u1ec9 m\u00f3n gi\u1ea3m gi\u00e1'),
              value: discountedOnly,
              onChanged: (value) => setState(() => discountedOnly = value),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                widget.provider.applyMenuFilters(
                  availability: availability,
                  minPrice: priceRange.start,
                  maxPrice: priceRange.end,
                  sortOption: sortOption,
                  discountedOnly: discountedOnly,
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('\u00c1p d\u1ee5ng'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetDraft() {
    setState(() {
      availability = ProductAvailabilityFilter.all;
      priceRange = RangeValues(
        widget.provider.priceFilterFloor,
        widget.provider.priceFilterCeiling,
      );
      sortOption = ProductSortOption.defaultOrder;
      discountedOnly = false;
    });
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.children,
    this.wrapChildren = true,
  });

  final String title;
  final List<Widget> children;
  final bool wrapChildren;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          wrapChildren
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: children,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
        ],
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _PriceRangeSlider extends StatelessWidget {
  const _PriceRangeSlider({
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _priceRangeLabel(values.start, values.end),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: loafMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        RangeSlider(
          min: min,
          max: max,
          divisions: _priceSliderDivisions(min, max),
          values: values,
          labels: RangeLabels(
            _formatPriceSliderLabel(values.start),
            _formatPriceSliderLabel(values.end),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

String _priceRangeLabel(double min, double max) =>
    '${_formatPriceSliderLabel(min)} - ${_formatPriceSliderLabel(max)}';

String _formatPriceSliderLabel(double price) {
  final rounded = price.round();
  if (rounded % 1000 == 0) {
    return '${rounded ~/ 1000}k';
  }
  return money(price);
}

int _priceSliderDivisions(double min, double max) {
  final divisions = ((max - min) / 10000).round();
  return divisions < 1 ? 1 : divisions;
}

String _sortOptionLabel(ProductSortOption option) {
  return switch (option) {
    ProductSortOption.defaultOrder => 'M\u1eb7c \u0111\u1ecbnh',
    ProductSortOption.nameAZ => 'T\u00ean A-Z',
    ProductSortOption.priceLowHigh => 'Gi\u00e1 Th\u1ea5p - Cao',
    ProductSortOption.priceHighLow => 'Gi\u00e1 Cao - Th\u1ea5p',
  };
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CafeImageFrame(
                  imageUrl: product.picture,
                  icon: Icons.inventory_2_outlined,
                  label: product.name,
                  borderRadius: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(product.categoryName,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: loafMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        CafeInfoChip(
                            label: AppStrings.stockCountLabel(
                                product.unitInStock)),
                        CafeInfoChip(
                            label: product.isAvailable
                                ? AppStrings.inStockLabel
                                : AppStrings.outOfStockLabel),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  money(product.displayPrice),
                  textAlign: TextAlign.right,
                  style: moneyTextStyle(theme.textTheme.titleMedium,
                      color: loafOrange, fontWeight: FontWeight.w800),
                ),
              ),
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

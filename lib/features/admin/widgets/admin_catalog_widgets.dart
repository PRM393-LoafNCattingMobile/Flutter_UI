part of '../screens/admin_catalog_screen.dart';

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
    return AdminSearchFilterHeader(
      searchController: searchController,
      searchHint: AppStrings.menuSearchHint,
      hasFilters: provider.hasProductFilters,
      onSearchSubmitted: provider.applySearch,
      onOpenFilters: onOpenFilters,
      onResetFilters: onResetFilters,
      activeFilters: _productActiveFilterData(provider, onClearSearch),
      choiceChips: provider.categories.isEmpty
          ? const []
          : [
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
    );
  }
}

List<AdminActiveFilterChipData> _productActiveFilterData(
  AdminCatalogProvider provider,
  VoidCallback onClearSearch,
) {
  String? selectedCategory;
  for (final category in provider.categories) {
    if (category.categoryId == provider.selectedCategoryId) {
      selectedCategory = category.name;
      break;
    }
  }

  return [
    if (provider.search.trim().isNotEmpty)
      AdminActiveFilterChipData(
        label: 'Tìm: ${provider.search.trim()}',
        onDeleted: onClearSearch,
      ),
    if (selectedCategory != null)
      AdminActiveFilterChipData(
        label: selectedCategory,
        onDeleted: provider.clearCategoryFilter,
      ),
    if (provider.availabilityFilter == ProductAvailabilityFilter.availableOnly)
      AdminActiveFilterChipData(
        label: AppStrings.inStockLabel,
        onDeleted: provider.clearAvailabilityFilter,
      ),
    if (provider.hasPriceFilter)
      AdminActiveFilterChipData(
        label: _priceRangeLabel(
          provider.priceFilterMin,
          provider.priceFilterMax,
        ),
        onDeleted: provider.clearPriceRangeFilter,
      ),
    if (provider.sortOption != ProductSortOption.defaultOrder)
      AdminActiveFilterChipData(
        label: _sortOptionLabel(provider.sortOption),
        onDeleted: provider.clearSortFilter,
      ),
    if (provider.discountedOnly)
      AdminActiveFilterChipData(
        label: 'Giảm giá',
        onDeleted: provider.clearDiscountFilter,
      ),
    if (provider.lowStockOnly)
      AdminActiveFilterChipData(
        label: 'Sắp hết',
        onDeleted: provider.clearLowStockFilter,
      ),
  ];
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
  late bool lowStockOnly;

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
    lowStockOnly = widget.provider.lowStockOnly;
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
                Text(AppStrings.filterSheetTitle,
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: _resetDraft,
                  child: const Text(AppStrings.resetButton),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AdminFilterSection(
              title: AppStrings.availabilityFilterTitle,
              children: [
                AdminFilterChoice(
                  label: AppStrings.allCategoryLabel,
                  selected: availability == ProductAvailabilityFilter.all,
                  onSelected: () => setState(
                      () => availability = ProductAvailabilityFilter.all),
                ),
                AdminFilterChoice(
                  label: AppStrings.inStockLabel,
                  selected:
                      availability == ProductAvailabilityFilter.availableOnly,
                  onSelected: () => setState(() =>
                      availability = ProductAvailabilityFilter.availableOnly),
                ),
              ],
            ),
            AdminFilterSection(
              title: AppStrings.priceFilterTitle,
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
            AdminFilterSection(
              title: AppStrings.sortFilterTitle,
              children: ProductSortOption.values
                  .map(
                    (option) => AdminFilterChoice(
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
              title: const Text(AppStrings.discountedOnlyLabel),
              value: discountedOnly,
              onChanged: (value) => setState(() => discountedOnly = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: loafOrange,
              title: const Text(AppStrings.adminLowStockOnlyLabel),
              value: lowStockOnly,
              onChanged: (value) => setState(() => lowStockOnly = value),
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
                  lowStockOnly: lowStockOnly,
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text(AppStrings.applyButton),
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
      lowStockOnly = false;
    });
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
                      IconButton(
                        onPressed: onEdit,
                        tooltip: AppStrings.adminEditProductAction,
                        icon: const Icon(Icons.edit_outlined),
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

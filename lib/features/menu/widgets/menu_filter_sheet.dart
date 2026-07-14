part of '../screens/menu_screen.dart';

Future<void> _showMenuFilters(
    BuildContext context, CatalogProvider catalog) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MenuFilterSheet(catalog: catalog),
  );
}

class _ActiveMenuFilters extends StatelessWidget {
  const _ActiveMenuFilters({required this.catalog});

  final CatalogProvider catalog;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (catalog.availabilityFilter ==
              ProductAvailabilityFilter.availableOnly)
            _ActiveFilterChip(
              label: 'C\u00f2n h\u00e0ng',
              onDeleted: catalog.clearAvailabilityFilter,
            ),
          if (catalog.hasPriceFilter)
            _ActiveFilterChip(
              label: _priceRangeLabel(
                  catalog.priceFilterMin, catalog.priceFilterMax),
              onDeleted: catalog.clearPriceRangeFilter,
            ),
          if (catalog.sortOption != ProductSortOption.defaultOrder)
            _ActiveFilterChip(
              label: _sortOptionLabel(catalog.sortOption),
              onDeleted: catalog.clearSortFilter,
            ),
          if (catalog.discountedOnly)
            _ActiveFilterChip(
              label: 'Gi\u1ea3m gi\u00e1',
              onDeleted: catalog.clearDiscountFilter,
            ),
          TextButton(
            onPressed: catalog.resetMenuFilters,
            child: const Text(AppStrings.resetButton),
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

class _MenuFilterSheet extends StatefulWidget {
  const _MenuFilterSheet({required this.catalog});

  final CatalogProvider catalog;

  @override
  State<_MenuFilterSheet> createState() => _MenuFilterSheetState();
}

class _MenuFilterSheetState extends State<_MenuFilterSheet> {
  late ProductAvailabilityFilter availability;
  late RangeValues priceRange;
  late ProductSortOption sortOption;
  late bool discountedOnly;

  @override
  void initState() {
    super.initState();
    availability = widget.catalog.availabilityFilter;
    priceRange = RangeValues(
      widget.catalog.priceFilterMin,
      widget.catalog.priceFilterMax,
    );
    sortOption = widget.catalog.sortOption;
    discountedOnly = widget.catalog.discountedOnly;
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
            _FilterSection(
              title: AppStrings.availabilityFilterTitle,
              children: [
                _FilterChoice(
                  label: 'T\u1ea5t c\u1ea3',
                  selected: availability == ProductAvailabilityFilter.all,
                  onSelected: () => setState(
                      () => availability = ProductAvailabilityFilter.all),
                ),
                _FilterChoice(
                  label: 'C\u00f2n h\u00e0ng',
                  selected:
                      availability == ProductAvailabilityFilter.availableOnly,
                  onSelected: () => setState(() =>
                      availability = ProductAvailabilityFilter.availableOnly),
                ),
              ],
            ),
            _FilterSection(
              title: AppStrings.priceFilterTitle,
              wrapChildren: false,
              children: [
                _PriceRangeSlider(
                  values: priceRange,
                  min: widget.catalog.priceFilterFloor,
                  max: widget.catalog.priceFilterCeiling,
                  onChanged: (values) => setState(() => priceRange = values),
                ),
              ],
            ),
            _FilterSection(
              title: AppStrings.sortFilterTitle,
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
              title: const Text(AppStrings.discountedOnlyLabel),
              value: discountedOnly,
              onChanged: (value) => setState(() => discountedOnly = value),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                widget.catalog.applyMenuFilters(
                  availability: availability,
                  minPrice: priceRange.start,
                  maxPrice: priceRange.end,
                  sortOption: sortOption,
                  discountedOnly: discountedOnly,
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
        widget.catalog.priceFilterFloor,
        widget.catalog.priceFilterCeiling,
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

import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';

class AdminActiveFilterChipData {
  const AdminActiveFilterChipData({
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;
}

class AdminSearchFilterHeader extends StatelessWidget {
  const AdminSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.hasFilters,
    required this.onSearchSubmitted,
    required this.onOpenFilters,
    required this.activeFilters,
    required this.onResetFilters,
    this.choiceChips = const [],
  });

  final TextEditingController searchController;
  final String searchHint;
  final bool hasFilters;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback? onOpenFilters;
  final List<AdminActiveFilterChipData> activeFilters;
  final VoidCallback onResetFilters;
  final List<Widget> choiceChips;

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
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: searchHint,
                  ),
                  onSubmitted: (value) => onSearchSubmitted(value.trim()),
                ),
              ),
              const SizedBox(width: 10),
              AdminFilterIconButton(
                hasFilters: hasFilters,
                onPressed: onOpenFilters,
              ),
            ],
          ),
        ),
        if (choiceChips.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: choiceChips,
            ),
          ),
        if (activeFilters.isNotEmpty)
          AdminActiveFilterBar(
            filters: activeFilters,
            onResetFilters: onResetFilters,
          ),
      ],
    );
  }
}

class AdminFilterIconButton extends StatelessWidget {
  const AdminFilterIconButton({
    super.key,
    required this.hasFilters,
    required this.onPressed,
  });

  final bool hasFilters;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                onPressed: onPressed,
                icon: const Icon(Icons.tune),
              ),
            ),
          ),
          if (hasFilters)
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
    );
  }
}

class AdminActiveFilterBar extends StatelessWidget {
  const AdminActiveFilterBar({
    super.key,
    required this.filters,
    required this.onResetFilters,
  });

  final List<AdminActiveFilterChipData> filters;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...filters.map(
            (filter) => AdminActiveFilterChip(
              label: filter.label,
              onDeleted: filter.onDeleted,
            ),
          ),
          TextButton(
            onPressed: onResetFilters,
            child: const Text(AppStrings.resetButton),
          ),
        ],
      ),
    );
  }
}

class AdminActiveFilterChip extends StatelessWidget {
  const AdminActiveFilterChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

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

class AdminFilterSection extends StatelessWidget {
  const AdminFilterSection({
    super.key,
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

class AdminFilterChoice extends StatelessWidget {
  const AdminFilterChoice({
    super.key,
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

class AdminDeleteConfirmDialog extends StatelessWidget {
  const AdminDeleteConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.adminDeleteConfirmTitle),
      content: const Text(AppStrings.adminDeleteConfirmMessage),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.adminCancelButton),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(AppStrings.adminDeleteButton),
            ),
          ],
        ),
      ],
    );
  }
}

Future<bool?> showAdminDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => const AdminDeleteConfirmDialog(),
  );
}

class AdminStatusFilterBar extends StatelessWidget {
  const AdminStatusFilterBar({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.selectedDate,
    this.onDateChanged,
    this.onReset,
  });

  final List<LookupItem> options;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final String? selectedDate;
  final ValueChanged<String?>? onDateChanged;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final showDateFilter = onDateChanged != null;
    final hasFilter = selectedId != null ||
        (selectedDate != null && selectedDate!.trim().isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          DropdownButtonFormField<int?>(
            initialValue: selectedId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: AppStrings.adminFilterByStatusLabel,
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text(AppStrings.adminFilterAllStatuses),
              ),
              ...options.map(
                (option) => DropdownMenuItem<int?>(
                  value: option.id,
                  child: Text(option.name),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
          if (showDateFilter) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(context),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(_dateFilterLabel(selectedDate)),
                  ),
                ),
                if (selectedDate != null && selectedDate!.trim().isNotEmpty)
                  IconButton(
                    tooltip: 'X\u00f3a ng\u00e0y',
                    onPressed: () => onDateChanged?.call(null),
                    icon: const Icon(Icons.close),
                  ),
                if (hasFilter && onReset != null)
                  TextButton(
                    onPressed: onReset,
                    child: const Text(AppStrings.resetButton),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = _parseAdminApiDate(selectedDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: loafOrange,
              ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null) return;
    onDateChanged?.call(formatAdminApiDate(picked));
  }
}

String formatAdminDateTime(DateTime dateTime) {
  String two(int value) => value.toString().padLeft(2, '0');
  final local = dateTime.toLocal();
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

String formatAdminApiDate(DateTime dateTime) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${two(dateTime.month)}-${two(dateTime.day)}';
}

String _dateFilterLabel(String? date) {
  final parsed = _parseAdminApiDate(date);
  if (parsed == null) return 'L\u1ecdc theo ng\u00e0y';
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year}';
}

DateTime? _parseAdminApiDate(String? date) {
  if (date == null || date.trim().isEmpty) return null;
  return DateTime.tryParse(date.trim());
}

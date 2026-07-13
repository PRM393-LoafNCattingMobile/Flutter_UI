import 'package:flutter/material.dart';
import 'package:loafncatting_mobile/core/constants/app_strings.dart';
import 'package:loafncatting_mobile/features/admin/models/admin_models.dart';
import 'package:loafncatting_mobile/theme/app_theme.dart';

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
                    child: const Text('Reset'),
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
  return '${two(dateTime.day)}/${two(dateTime.month)}/${dateTime.year} '
      '${two(dateTime.hour)}:${two(dateTime.minute)}';
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
